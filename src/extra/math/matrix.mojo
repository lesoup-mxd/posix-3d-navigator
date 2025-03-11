from math import sqrt, sin, cos, tan


struct Matrix4f:
    """
    A 4x4 matrix of floats, commonly used for 3D transformations.
    The matrix is stored in column-major order.
    """

    var data: SIMD[DType.float32, 16]

    fn __init__(mut self):
        """Initialize as identity matrix."""
        self.data = SIMD[DType.float32, 16](0)
        self.data[0] = 1.0
        self.data[5] = 1.0
        self.data[10] = 1.0
        self.data[15] = 1.0

    fn __init__(
        mut self,
        m00: Float32,
        m01: Float32,
        m02: Float32,
        m03: Float32,
        m10: Float32,
        m11: Float32,
        m12: Float32,
        m13: Float32,
        m20: Float32,
        m21: Float32,
        m22: Float32,
        m23: Float32,
        m30: Float32,
        m31: Float32,
        m32: Float32,
        m33: Float32,
    ):
        """Initialize with individual elements."""
        self.data = SIMD[DType.float32, 16](
            m00,
            m10,
            m20,
            m30,
            m01,
            m11,
            m21,
            m31,
            m02,
            m12,
            m22,
            m32,
            m03,
            m13,
            m23,
            m33,
        )

    fn __init__(mut self, other: Self):
        """Copy constructor."""
        self.data = other.data

    fn __copyinit__(mut self, existing: Self):
        """Copy from another matrix."""
        self.data = existing.data

    @staticmethod
    fn identity() -> Self:
        """Create an identity matrix."""
        return Self()

    @staticmethod
    fn translation(x: Float32, y: Float32, z: Float32) -> Self:
        """Create a translation matrix."""
        var result = Self()
        result.data[3] = x
        result.data[7] = y
        result.data[11] = z
        return result

    @staticmethod
    fn scaling(x: Float32, y: Float32, z: Float32) -> Self:
        """Create a scaling matrix."""
        var result = Self()
        result.data[0] = x
        result.data[5] = y
        result.data[10] = z
        return result

    @staticmethod
    fn rotation_x(angle_rad: Float32) -> Self:
        """Create a rotation matrix around X axis."""
        var result = Self()
        var s = sin(angle_rad)
        var c = cos(angle_rad)
        result.data[5] = c
        result.data[6] = s
        result.data[9] = -s
        result.data[10] = c
        return result

    @staticmethod
    fn rotation_y(angle_rad: Float32) -> Self:
        """Create a rotation matrix around Y axis."""
        var result = Self()
        var s = sin(angle_rad)
        var c = cos(angle_rad)
        result.data[0] = c
        result.data[2] = -s
        result.data[8] = s
        result.data[10] = c
        return result

    @staticmethod
    fn rotation_z(angle_rad: Float32) -> Self:
        """Create a rotation matrix around Z axis."""
        var result = Self()
        var s = sin(angle_rad)
        var c = cos(angle_rad)
        result.data[0] = c
        result.data[1] = s
        result.data[4] = -s
        result.data[5] = c
        return result

    @staticmethod
    fn perspective(
        fov_y: Float32, aspect: Float32, near: Float32, far: Float32
    ) -> Self:
        """Create a perspective projection matrix."""
        var result = Self()
        var f = 1.0 / tan(fov_y / 2.0)

        result.data[0] = f / aspect
        result.data[5] = f
        result.data[10] = (far + near) / (near - far)
        result.data[11] = (2.0 * far * near) / (near - far)
        result.data[14] = -1.0
        result.data[15] = 0.0

        return result

    fn __mul__(self, other: Self) -> Self:
        """Matrix multiplication."""
        var result = Self()

        for i in range(4):
            for j in range(4):
                var sum: Float32 = 0.0
                for k in range(4):
                    sum += self.get(i, k) * other.get(k, j)
                result.set(i, j, sum)

        return result

    fn transpose(self) -> Self:
        """Return the transpose of this matrix."""
        var result = Self()

        for i in range(4):
            for j in range(4):
                result.set(j, i, self.get(i, j))

        return result

    fn determinant(self) -> Float32:
        """Calculate the determinant of the matrix."""
        # Implementation for 4x4 determinant
        # This is a simplified version; a more efficient implementation would be preferred for production

        var a = self.get(0, 0)
        var b = self.get(0, 1)
        var c = self.get(0, 2)
        var d = self.get(0, 3)
        var e = self.get(1, 0)
        var f = self.get(1, 1)
        var g = self.get(1, 2)
        var h = self.get(1, 3)
        var i = self.get(2, 0)
        var j = self.get(2, 1)
        var k = self.get(2, 2)
        var l = self.get(2, 3)
        var m = self.get(3, 0)
        var n = self.get(3, 1)
        var o = self.get(3, 2)
        var p = self.get(3, 3)

        return (
            a * f * k * p
            - a * f * l * o
            - a * g * j * p
            + a * g * l * n
            + a * h * j * o
            - a * h * k * n
            - b * e * k * p
            + b * e * l * o
            + b * g * i * p
            - b * g * l * m
            - b * h * i * o
            + b * h * k * m
            + c * e * j * p
            - c * e * l * n
            - c * f * i * p
            + c * f * l * m
            + c * h * i * n
            - c * h * j * m
            - d * e * j * o
            + d * e * k * n
            + d * f * i * o
            - d * f * k * m
            - d * g * i * n
            + d * g * j * m
        )

    fn get(self, row: Int, col: Int) -> Float32:
        """Get an element at the specified position."""
        return self.data[col * 4 + row]

    fn set(mut self, row: Int, col: Int, value: Float32):
        """Set an element at the specified position."""
        self.data[col * 4 + row] = value
