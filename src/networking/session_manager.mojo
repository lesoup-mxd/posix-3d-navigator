# Honestly, i got no idea when networking will reach the "working" state

from collections import Dict
from memory import UnsafePointer, OwnedPointer
import time


struct SessionManager:
    var is_connected: Bool
    var session_id: String
    var user_id: String
    var username: String
    var auth_token: String
    var server_address: String
    var port: Int

    # Callback
    var event_callback: fn (String, Dict[String, String])
    # State
    var connected: Bool

    fn __init__(
        mut self,
        username: String,
    ):
        self.is_connected = False
        self.connected = False
        self.session_id = "session_" + String(
            Int(time.perf_counter())
        )  # Placeholder, should be managed by account server
        self.user_id = "user_" + String(Int(time.perf_counter()))  # Placeholder
        self.username = username
        self.auth_token = ""  # Placeholder
        self.is_connected = False
        self.server_address = "localhost"
        self.port = 8080

        fn default_event_callback(
            event: String,
            data: Dict[String, String],
        ):
            # Default event callback
            print("Event:", event)
            for i in data:
                try:
                    print("Data:", i[], "=", data[i[]])
                except:
                    print("Error accessing data for key:", i[])

        self.event_callback = default_event_callback  # Default callback

    fn set_event_callback(
        mut self,
        handler: fn (String, Dict[String, String]),
    ):
        self.event_callback = handler

    fn connect(mut self, server: String, port: Int) -> Bool:
        # Connect to server
        print("Connecting to server:", server, "port:", port)
        self.server_address = server
        self.port = port
        self.is_connected = True
        self.connected = True
        return self.is_connected

    fn authenticate(mut self, username: String, password: String) -> Bool:
        # Authenticate with server
        if not self.is_connected:
            print("Not connected to server")
            return False

        print("Authenticating user:", username)
        self.username = username
        self.session_id = "session_" + String(Int(time.perf_counter()))
        self.auth_token = "auth_token_" + String(Int(time.perf_counter()))
        return True

    fn send_request(self, endpoint: String, data: String) -> String:
        # Send request to server
        if not self.is_connected:
            print("Not connected to server")
            return ""

        print("Sending request to:", endpoint)
        return '{"status": "success", "data": {}}'  # Placeholder

    fn disconnect(mut self):
        # Disconnect from server
        if self.is_connected:
            print("Disconnecting from server")
            self.is_connected = False
            self.connected = False
            self.session_id = ""
            self.auth_token = ""

    fn get_user_id(self) -> String:
        return self.user_id

    fn is_active(self) -> Bool:
        return self.connected

    fn send_position_update(
        self,
        x: Float32,
        y: Float32,
        z: Float32,
        rx: Float32,
        ry: Float32,
        rz: Float32,
        path: String,
    ):
        if not self.is_connected:
            return

        print(
            '"Broadcasting" position:',
            x,
            y,
            z,
            "to other users\nPlease implement networking code :)",
        )
        # In real implementation, this would send the data over network

        # Example of calling the callback for testing
        var data = Dict[String, String]()
        data["user_id"] = self.user_id
        data["x"] = String(x)
        data["y"] = String(y)
        data["z"] = String(z)
        data["rx"] = String(rx)
        data["ry"] = String(ry)
        data["rz"] = String(rz)
        data["path"] = path

        # Comment this out if you want to avoid recursive callbacks in testing
        self.event_callback("position_update", data)
