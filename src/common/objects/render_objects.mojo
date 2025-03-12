from extra.math.vector import Vector3f


@value
struct Object3D:
    var id: String
    var pos: Vector3f
    var rot: Vector3f
    var scale: Vector3f

    fn __eq__(self, other: Self) -> Bool:
        return self.id == other.id
