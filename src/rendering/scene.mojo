# This file manages the overall scene, including the addition and removal of objects, as well as the rendering process.

# TODO: remove the placeholder
from extra.math.vector import Vector3f


@value
struct Object3D:
    var id: String
    var pos: Vector3f
    var rot: Vector3f
    var scale: Vector3f


struct Scene:
    var objects: List[Object3D]

    fn __init__(mut self):
        self.objects = List[Object3D]()

        def addObject(mut self, object: Object3D):
            self.objects.append()

        def removeObject(mut self, object: Object3D):
            self.objects.remove(object)

        def render(mut self):
            for i in range(len(self.objects)):
                object = self.objects[i]
                object.render()
