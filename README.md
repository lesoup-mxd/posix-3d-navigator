# POSIX 3D Navigator

## Overview

The POSIX 3D Navigator is an interactive application that allows users to explore the POSIX file system in a 3D environment. Utilizing Vulkan for high-performance rendering and Mojo for core logic, this project provides a unique way to visualize and navigate through directories and files in a multiplayer 3D space.

## Features

- 3D visualization of the POSIX file system with Tron-inspired aesthetics
- High-performance Vulkan rendering for smooth graphics
- User-friendly controls for navigation and interaction
- Dynamic loading and management of 3D models representing files and directories
- Multi-user support for collaborative file system exploration
- Symlinks visualized as portals between locations

## Project Structure

``` $
posix-3d-navigator/
  README.md                     # Project documentation
  build.mojo                    # Build configuration for Mojo project

  src/                          # Main source directory
    main.mojo                   # Entry point of the application
    
    filesystem/                 # File system traversal logic
      posix_walker.mojo         # Logic to navigate POSIX file system
      file_metadata.mojo        # Metadata management for files
    
    rendering/                  # Rendering logic
      renderer.mojo             # Vulkan rendering pipeline setup
      vulkan_interface.mojo     # Vulkan API interface
      camera.mojo               # Camera management for 3D view
      window.mojo               # Window management
      scene.mojo                # Scene management for rendering
      models.mojo               # 3D model management
    
    networking/                 # Multiplayer networking components
      session_manager.mojo      # Session and user management
    
    common/                     # Common data structures
      objects/                  # Object definitions
        files.mojo              # File object structures
        users.mojo              # User identity structures
        render_objects.mojo     # Rendering object structures
    
    extra/                      # Extra utilities
      math/                     # Math utilities
        vector.mojo             # Vector math operations
        matrix.mojo             # Matrix math operations
    
    input/                      # User input handling
      controls.mojo             # Navigation and interaction controls

  cpp_lib/                      # C++ library for Vulkan
    vulkan_wrapper.cpp          # Implementation of Vulkan wrapper functions
    vulkan_wrapper.h            # Declaration of Vulkan wrapper functions
    CMakeLists.txt              # Build configuration for C++ library

  assets/                       # Assets for the application
    shaders/                    # Shader files
      vertex.glsl               # Vertex shader source
      fragment.glsl             # Fragment shader source (Phong lighting model)
```

## Setup Instructions

1. Clone the repository:

   ``` $
   git clone https://github.com/lesoup-mxd/posix-3d-navigator.git
   ```

2. Navigate to the project directory:

   ``` $
   cd posix-3d-navigator
   ```

3. Install Vulkan SDK

   This part depends on your distribution / Operating system. Please check your preferred mirrors for Vulkan SDK package.

5. Build the C++ library:

   ``` $
   cd cpp_lib
   mkdir build && cd build
   cmake ..
   make
   ```

   This will generate the `libvulkan_wrapper.so` shared library.
6. Run the Mojo application:

   ``` $
   mojo src/main.mojo
   ```

## Usage

- Use the arrow keys or WASD to navigate through the 3D environment.
- Use E/Q or PgUp/PgDn to move up and down.
- Look around with mouse movement.
- Click on files and directories to interact with them.
- Press Tab to open a terminal command prompt overlay.
- To enable multiplayer, start with the `-m` flag and specify a username.

## Multiplayer

To start a multiplayer session:

``` $
mojo src/main.mojo -m -u YourUsername
```

To join an existing session:

``` $
mojo src/main.mojo -m -u YourUsername -s server_address
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.

## License

The licence for this project is currently under development. Please check back later for more information.
