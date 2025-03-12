from extra.math.vector import Vector3f


@value
struct UserIdentity:
    var user_id: String
    var username: String
    var position: Vector3f
    var rotation: Vector3f
    var color: Vector3f
    var active: Bool
