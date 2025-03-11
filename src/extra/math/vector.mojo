# Simple 3D vector implementation for Mojo
import math


@value
struct Vector3f:
    var x: Float32
    var y: Float32
    var z: Float32

    fn __init__(mut self, x: Float32 = 0.0, y: Float32 = 0.0, z: Float32 = 0.0):
        self.x = x
        self.y = y
        self.z = z

    # Basic vector operations
    fn __add__(self, other: Vector3f) -> Vector3f:
        return Vector3f(self.x + other.x, self.y + other.y, self.z + other.z)

    fn __sub__(self, other: Vector3f) -> Vector3f:
        return Vector3f(self.x - other.x, self.y - other.y, self.z - other.z)

    fn __mul__(self, scalar: Float32) -> Vector3f:
        return Vector3f(self.x * scalar, self.y * scalar, self.z * scalar)

    fn __truediv__(self, scalar: Float32) -> Vector3f:
        return Vector3f(self.x / scalar, self.y / scalar, self.z / scalar)

    # Dot product
    fn dot(self, other: Vector3f) -> Float32:
        return self.x * other.x + self.y * other.y + self.z * other.z

    # Cross product
    fn cross(self, other: Vector3f) -> Vector3f:
        return Vector3f(
            self.y * other.z - self.z * other.y,
            self.z * other.x - self.x * other.z,
            self.x * other.y - self.y * other.x,
        )

    # Length squared (for efficiency when only comparing lengths)
    fn length_squared(self) -> Float32:
        return self.x * self.x + self.y * self.y + self.z * self.z

    # Vector length/magnitude
    fn length(self) -> Float32:
        return math.sqrt(self.length_squared())

    # Normalized vector (unit length)
    fn normalized(self) -> Vector3f:
        var len = self.length()
        if len > 0.00001:  # Avoid division by zero
            return self / len
        return Vector3f(0, 0, 0)


@value
struct Vector3i:
    var x: Int
    var y: Int
    var z: Int

    fn __init__(mut self, x: Int = 0, y: Int = 0, z: Int = 0):
        self.x = x
        self.y = y
        self.z = z

    # Basic vector operations
    fn __add__(self, other: Vector3i) -> Vector3i:
        return Vector3i(self.x + other.x, self.y + other.y, self.z + other.z)

    fn __sub__(self, other: Vector3i) -> Vector3i:
        return Vector3i(self.x - other.x, self.y - other.y, self.z - other.z)

    fn __mul__(self, scalar: Int) -> Vector3i:
        return Vector3i(self.x * scalar, self.y * scalar, self.z * scalar)

    # Convert to float vector
    fn to_float(self) -> Vector3f:
        return Vector3f(Float32(self.x), Float32(self.y), Float32(self.z))
