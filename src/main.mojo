# This file serves as the entry point of the application. It initializes the OpenGL context, sets up the main loop, and handles the overall application flow.

import filesystem.posix_walker
import rendering.renderer
import rendering.camera
import rendering.scene
import input.controls


@value
struct Main:
    var window: Window
    var renderer: Renderer
    var camera: Camera
    var scene: Scene
    var posixWalker: PosixWalker
    var controls: Controls

    fn initialize(mut self):
        window = Window.create("POSIX 3D Navigator", 800, 600)
        OpenGL.initialize()
        renderer = Renderer()
        camera = Camera()
        scene = Scene()
        posixWalker = PosixWalker()
        controls = Controls()

    fn mainLoop(mut self):
        while window.isOpen():
            controls.update()
            posixWalker.update()
            scene.update()
            renderer.render(scene, camera)
            window.swapBuffers()

    fn run(mut self):
        initialize()
        mainLoop()


fn main():
    var app = Main()
    app.run()
