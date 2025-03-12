# This file implements the logic to traverse the POSIX file system in a 3D multiplayer environment.

import os
import time
import math
import pathlib
from os import path
from collections import Dict, List, Set

from filesystem.file_metadata import FileMetadata
from rendering.vulkan_interface import VulkanRenderer, FileObjectEntity
from networking.session_manager import SessionManager
from extra.math.vector import Vector3f, Vector3i


@value
struct FileObject:
    var metadata: FileMetadata
    var position: Vector3f
    var rotation: Vector3f
    var scale: Vector3f
    var color: Vector3f
    var object_id: String  # Unique ID for networking


@value
struct UserIdentity:
    var user_id: String
    var username: String
    var position: Vector3f
    var rotation: Vector3f
    var color: Vector3f
    var active: Bool


struct PosixWalker:
    var currentPath: String
    var previousPaths: List[String]  # History for navigation
    var renderer: VulkanRenderer
    var session: SessionManager
    var fileObjects: Dict[String, FileObject]
    var users: Dict[String, UserIdentity]
    var localUserId: String

    # Callback for event handling
    var event_callback: fn (String, Dict[String, String])

    # Room dimensions based on directory contents
    var roomWidth: Float32
    var roomHeight: Float32
    var roomDepth: Float32

    fn __init__(
        mut self,
        path: String = "",
        multiplayer: Bool = False,
        username: String = "",
    ):
        # Initialize room
        self.roomWidth = 20
        self.roomHeight = 5
        self.roomDepth = 20
        if path:
            self.currentPath = path
        else:
            try:
                self.currentPath = pathlib.cwd().__str__()
            except e:
                print("Error getting current working directory:", e)
                self.currentPath = "/"
        self.previousPaths = List[String]()
        self.fileObjects = Dict[String, FileObject]()
        self.users = Dict[String, UserIdentity]()

        # Initialize renderer
        self.renderer = VulkanRenderer()
        # Set up multiplayer if requested
        self.session = SessionManager(
            username=username,
        )
        self.localUserId = self.session.get_user_id()

        # Create local user avatar (Tron identity disc)
        var local_user = UserIdentity(
            user_id=self.localUserId,
            username=username if username else "User-" + self.localUserId[:8],
            position=Vector3f(0.0, 1.0, 0.0),
            rotation=Vector3f(0.0, 0.0, 0.0),
            color=Vector3f(0.0, 0.8, 1.0),  # Tron blue
            active=True,
        )
        self.users[self.localUserId] = local_user
        self.event_callback = fn (String, Dict[String, String]): pass
        #TODO: pass the event callback to the session manager, placeholder does not want to compile

        if not self.renderer.initialize():
            print("Failed to initialize Vulkan renderer")
            return
        # Initial scan of the directory
        self.scan_directory()

    fn navigate_to(mut self, target_path: String) -> Bool:
        # Store current path in history for "back" navigation
        self.previousPaths.append(self.currentPath)

        # Handle special navigation cases
        if target_path == "..":
            var parent = os.path.dirname(self.currentPath)
            if parent == self.currentPath:  # Already at root
                return False
            self.currentPath = parent
        elif target_path.startswith("~"):
            try:
                self.currentPath = os.path.expanduser(target_path)
                if not os.path.exists(self.currentPath):
                    print("Invalid path:", self.currentPath)
                    return False
            except e:
                print("Error expanding user directory:", e)
                return False
        elif target_path == ".":
            # Stay in the current directory
            return True
        elif target_path.startswith("../"):
            # Relative path to parent directory
            var new_path = os.path.join(
                self.currentPath, target_path[3:]
            )  # Skip "../"
            if os.path.exists(new_path) and os.path.isdir(new_path):
                self.currentPath = new_path
            else:
                print("Invalid path:", new_path)
                return False
        elif target_path.startswith("./"):
            # Relative path to current directory
            var new_path = os.path.join(
                self.currentPath, target_path[2:]
            )  # Skip "./"
            if os.path.exists(new_path) and os.path.isdir(new_path):
                self.currentPath = new_path
            else:
                print("Invalid path:", new_path)
                return False
        elif target_path.startswith("/"):
            # Absolute path
            if os.path.exists(target_path) and os.path.isdir(target_path):
                self.currentPath = target_path
            else:
                print("Invalid path:", target_path)
                return False
        else:
            # Relative path
            var new_path = os.path.join(self.currentPath, target_path)
            if os.path.exists(new_path) and os.path.isdir(new_path):
                self.currentPath = new_path
            else:
                print("Invalid path:", new_path)
                return False

        # Scan the new directory and update visualization
        self.scan_directory()

        # Broadcast position change in multiplayer
        if self.session.is_active():
            self.broadcast_user_moved()

        return True

    fn navigate_back(mut self) -> Bool:
        if len(self.previousPaths) > 0:
            var prev_path = self.previousPaths.pop()
            self.currentPath = prev_path
            self.scan_directory()
            return True
        return False

    fn scan_directory(mut self):
        try:
            var entries = os.listdir(self.currentPath)
            var dir_count = 0
            var file_count = 0

            # Clear previous file objects
            self.fileObjects.clear()

            # Calculate room dimensions based on content
            self.calculate_room_dimensions(len(entries))

            # First pass - count directories and files for layout
            for _entry in range(len(entries)):
                var entry = entries[_entry]
                var full_path = os.path.join(self.currentPath, entry)
                if os.path.isdir(full_path):
                    dir_count += 1
                else:
                    file_count += 1

            # Second pass - create file objects with positions
            var dir_index = 0
            var file_index = 0

            for _entry in range(len(entries)):
                var entry = entries[_entry]
                var full_path = os.path.join(self.currentPath, entry)
                var is_dir = os.path.isdir(full_path)
                var is_symlink = os.path.islink(full_path)

                var file_size = 0
                try:
                    file_size = os.path.getsize(full_path) if not is_dir else 0
                except:
                    pass
                var filestat = os.stat(full_path)
                var metadata = FileMetadata(
                    name=entry,
                    path=full_path,
                    size=file_size,
                    isDirectory=is_dir,
                    createdTime=UInt64(filestat.st_ctimespec.tv_sec),
                    modifiedTime=UInt64(filestat.st_mtimespec.tv_sec),
                    accessedTime=UInt64(filestat.st_atimespec.tv_sec),
                )

                # Position calculation
                var position = Vector3f(0.0, 0.0, 0.0)
                var color = Vector3f(0.7, 0.7, 0.7)  # Default color
                var scale = Vector3f(1.0, 1.0, 1.0)

                if is_dir:
                    # Directories positioned on the walls
                    position = self.calculate_directory_position(
                        dir_index, dir_count
                    )
                    color = Vector3f(0.2, 0.6, 1.0)  # Blue for directories
                    scale = Vector3f(1.5, 1.5, 1.5)
                    dir_index += 1
                elif is_symlink:
                    # Symlinks positioned as portals
                    position = self.calculate_file_position(
                        file_index, file_count
                    )
                    color = Vector3f(1.0, 0.5, 1.0)  # Purple for symlinks
                    scale = Vector3f(0.8, 0.8, 0.8)
                    file_index += 1
                else:
                    # Regular files on the floor
                    position = self.calculate_file_position(
                        file_index, file_count
                    )
                    color = self.get_color_for_file_type(entry)
                    _scale = Float32(0.5 + (file_size / 1000000.0) * 0.5)
                    if _scale > 2.0:
                        _scale = 2.0  # Cap the maximum size
                    scale = Vector3f(
                        _scale, _scale, _scale
                    )  # Scale based on file size
                    # Size affects scale
                    file_index += 1

                # Create file object with unique ID for networking
                var object_id = full_path.replace("/", "_") + "_" + String(
                    Int(time.perf_counter())
                )
                var file_obj = FileObject(
                    metadata=metadata,
                    position=position,
                    rotation=Vector3f(0.0, 0.0, 0.0),
                    scale=scale,
                    color=color,
                    object_id=object_id,
                )

                self.fileObjects[object_id] = file_obj

                # Add to renderer
                _ = self.renderer.add_file_object(
                    FileObjectEntity(
                        full_path=full_path,
                        pos=position,
                        scale=scale,
                        color=color,
                        is_dir=is_dir,
                        is_symlink=is_symlink,
                    )
                )

            # Update room in renderer
            _ = self.renderer.update_file_object(
                FileObjectEntity(
                    full_path=self.currentPath,
                    pos=Vector3f(0.0, 0.0, 0.0),
                    scale=Vector3f(
                        self.roomWidth, self.roomHeight, self.roomDepth
                    ),
                    color=Vector3f(1.0, 1.0, 1.0),  # White for room
                    is_dir=False,
                    is_symlink=False,
                )
            )

        except:
            print("Error scanning directory:", self.currentPath)

    fn calculate_room_dimensions(mut self, entry_count: Int):
        # Adjust room size based on number of entries
        var base_size: Float32 = 10.0
        var scale_factor: Float32 = Float32(max(1.0, entry_count / 10))

        self.roomWidth = base_size * scale_factor
        self.roomHeight = 5 + scale_factor  # Height grows more slowly
        self.roomDepth = base_size * scale_factor

        # Cap maximum dimensions
        if self.roomWidth > 50:
            self.roomWidth = 50
        if self.roomHeight > 15:
            self.roomHeight = 15
        if self.roomDepth > 50:
            self.roomDepth = 50

    fn calculate_directory_position(self, index: Int, total: Int) -> Vector3f:
        # Directories are positioned along the walls
        var segment: Float32 = Float32(index / (total / 4))  # Which wall (0-3)
        var pos_on_wall: Float32 = Float32(
            index % (total / 4 + 1)
        )  # Position along that wall
        var wall_length: Float32 = 0.0

        if segment % 2 == 0:  # North/South walls
            wall_length = self.roomWidth
        else:  # East/West walls
            wall_length = self.roomDepth

        var spacing = wall_length / Float32((total / 4) + 1)
        var x: Float32 = 0.0
        var z: Float32 = 0.0

        if segment == 0:  # North wall
            x = Float32(spacing * pos_on_wall - self.roomWidth / 2)
            z = Float32(-self.roomDepth / 2)
        elif segment == 1:  # East wall
            x = Float32(self.roomWidth / 2)
            z = Float32(spacing * pos_on_wall - self.roomDepth / 2)
        elif segment == 2:  # South wall
            x = Float32(spacing * pos_on_wall - self.roomWidth / 2)
            z = Float32(self.roomDepth / 2)
        else:  # West wall
            x = Float32(-self.roomWidth / 2)
            z = Float32(spacing * pos_on_wall - self.roomDepth / 2)

        return Vector3f(x, 1.0, z)

    fn calculate_file_position(self, index: Int, total: Int) -> Vector3f:
        # Files are arranged in a grid pattern on the floor
        var grid_size = Int(math.ceil(math.sqrt(total)))
        var row = index // grid_size
        var col = index % grid_size

        var cell_width = self.roomWidth / grid_size
        var cell_depth = self.roomDepth / grid_size

        var x = col * cell_width - self.roomWidth / 2 + cell_width / 2
        var z = row * cell_depth - self.roomDepth / 2 + cell_depth / 2

        return Vector3f(x, 0.5, z)  # Files float slightly above the ground

    fn get_color_for_file_type(self, filename: String) -> Vector3f:
        var extension: String = ""
        var last_dot = filename.rfind(".")
        if last_dot >= 0:
            extension = filename[last_dot:].lower()

        if extension in [".txt", ".md", ".py", ".mojo"]:
            return Vector3f(0.9, 0.9, 0.2)  # Yellow for text/code
        elif extension in [".jpg", ".png", ".gif", ".bmp"]:
            return Vector3f(0.2, 0.9, 0.2)  # Green for images
        elif extension in [".mp3", ".wav", ".ogg"]:
            return Vector3f(0.9, 0.2, 0.9)  # Purple for audio
        elif extension in [".mp4", ".avi", ".mov"]:
            return Vector3f(0.2, 0.2, 0.9)  # Blue for video
        elif extension in [".zip", ".tar", ".gz"]:
            return Vector3f(0.6, 0.4, 0.2)  # Brown for archives
        elif extension in [".pdf", ".doc", ".docx"]:
            return Vector3f(0.9, 0.5, 0.2)  # Orange for documents
        elif extension in [".exe", ".app", ".sh"]:
            return Vector3f(0.9, 0.2, 0.2)  # Red for executables

        # Default gray
        return Vector3f(0.7, 0.7, 0.7)

    fn update_user_position(mut self, position: Vector3f, rotation: Vector3f):
        if self.localUserId in self.users:
            var user: UserIdentity
            try:
                user = self.users[self.localUserId]
            except e:
                print("Error accessing local user:", e)
                return
            user.position = position
            user.rotation = rotation
            self.users[self.localUserId] = user

            # Construct user identity
            var user_identity = UserIdentity(
                user_id=user.user_id,
                username=user.username,
                position=user.position,
                rotation=user.rotation,
                color=user.color,
                active=True,
            )
            # Update in renderer
            _ = self.renderer.update_user_position(user_identity)

            # Broadcast position if in multiplayer
            if self.session.is_active():
                self.broadcast_user_moved()

    fn broadcast_user_moved(self):
        if self.session.is_active() and self.localUserId in self.users:
            var user: UserIdentity
            try:
                user = self.users[self.localUserId]
            except e:
                print("Error accessing local user:", e)
                return
            var pos = user.position
            var rot = user.rotation

            # Send position update to server
            self.session.send_position_update(
                pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, self.currentPath
            )

    fn handle_network_event(
        mut self, event_type: String, data: Dict[String, String]
    ):
        if event_type == "user_joined":
            var user_id = String("")
            var username = String("")
            try:
                user_id = data["user_id"]
                username = data["username"]
            except e:
                print("Error parsing user join data:", e)
                return

            # Create new user identity
            var new_user = UserIdentity(
                user_id=user_id,
                username=username,
                position=Vector3f(0.0, 1.0, 0.0),
                rotation=Vector3f(0.0, 0.0, 0.0),
                color=Vector3f(0.8, 0.2, 0.2),  # Default red for other users
                active=True,
            )

            self.users[user_id] = new_user
            _ = self.renderer.add_user_object(new_user)

        elif event_type == "user_left":
            var user_id: String = ""
            try:
                user_id = data["user_id"]
            except e:
                if self.localUserId in self.users:
                    user_id = self.localUserId
                else:
                    return
            if user_id in self.users:
                try:
                    _ = self.users.pop(user_id)
                except e:
                    print("Error removing user:", e)
                # Remove user from renderer
                try:
                    pass  # TODO: change return type of register/unregister functions to UserIdentity/Bool. This way we can pass less redundant data
                    # self.renderer.remove_user_object(user_id)
                except e:
                    print("Error unregistering user from renderer:", e)

        elif event_type == "position_update":
            try:
                var user_id = data["user_id"]
                var x = Float32(Float64(data["x"]))
                var y = Float32(Float64(data["y"]))
                var z = Float32(Float64(data["z"]))
                var rx = Float32(Float64(data["rx"]))
                var ry = Float32(Float64(data["ry"]))
                var rz = Float32(Float64(data["rz"]))
                var path = data["path"]

                if user_id in self.users:
                    var user = self.users[user_id]
                    user.position = Vector3f(x, y, z)
                    user.rotation = Vector3f(rx, ry, rz)
                    self.users[user_id] = user
                    # Construct user identity
                    var user_identity = UserIdentity(
                        user_id=user.user_id,
                        username=user.username,
                        position=user.position,
                        rotation=user.rotation,
                        color=user.color,
                        active=True,
                    )

                    # Update user in renderer
                    _ = self.renderer.update_user_position(user_identity)

                    # Show notification if user is in different directory
                    if path != self.currentPath:
                        self.renderer.show_user_location_indicator(user_id)
                        # TODO: Maybe define this within the struct?
                        # This way we can unify the userobject update logic
            except e:
                print("Error processing position update:", e)
