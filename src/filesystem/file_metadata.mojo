struct FileMetadata:
    var name: String
    var path: String
    var size: UInt64
    var isDirectory: Bool
    var createdTime: UInt64
    var modifiedTime: UInt64
    var accessedTime: UInt64

    fn __init__(
        mut self,
        name: String,
        path: String,
        size: UInt64,
        isDirectory: Bool,
        createdTime: UInt64,
        modifiedTime: UInt64,
        accessedTime: UInt64,
    ):
        self.name = name
        self.path = path
        self.size = size
        self.isDirectory = isDirectory
        self.createdTime = createdTime
        self.modifiedTime = modifiedTime
        self.accessedTime = accessedTime

    fn __copyinit__(mut self, existing: Self):
        self.name = existing.name
        self.path = existing.path
        self.size = existing.size
        self.isDirectory = existing.isDirectory
        self.createdTime = existing.createdTime
        self.modifiedTime = existing.modifiedTime
        self.accessedTime = existing.accessedTime

    fn getFileMetadata(mut self, filePath: String):
        pass

    # Implementation to retrieve file metadata based on the filePath

    fn listDirectoryContents(mut self, directoryPath: String):
        pass

    # Implementation to list contents of a directory and return their metadata
