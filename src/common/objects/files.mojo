from extra.math.vector import Vector3f
from filesystem.file_metadata import FileMetadata


@value
struct FileObject:
    var metadata: FileMetadata
    var position: Vector3f
    var rotation: Vector3f
    var scale: Vector3f
    var color: Vector3f
    var object_id: String  # Unique ID for networking


@value
struct FileObjectEntity:
    var full_path: String
    var pos: Vector3f
    var scale: Vector3f
    var color: Vector3f
    var is_dir: Bool
    var is_symlink: Bool
