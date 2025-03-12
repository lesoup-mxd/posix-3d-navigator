# This file manages the overall scene, including the addition and removal of objects, as well as the rendering process.

# TODO: remove the placeholder
from extra.math.vector import Vector3f

from common.objects.render_objects import Object3D


struct Scene:
    var objects: List[Object3D]

    fn __init__(mut self):
        self.objects = List[Object3D]()

    fn addObject(mut self, object: Object3D) -> UInt:
        for _obj in range(len(self.objects)):
            obj = self.objects[_obj]
            # Check if the object already exists in th e scene
            if obj == object:
                return 2  # Object already exists, no need to add it again
        # Add the object to the scene
        self.objects.append(object)
        return 1  # Object added successfully

    fn removeObject(mut self, object: Object3D):
        for i in range(len(self.objects)):
            if self.objects[i] == object:
                _ = self.objects.pop(i)
                return

    def render(mut self):
        pass
        # TODO: Figure out where render calls should be
