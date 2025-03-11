#ifndef GL_WRAPPER_H
#define GL_WRAPPER_H

#include <GL/gl.h>

class GLWrapper {
public:
    static void initialize();
    static void clear(float r, float g, float b, float a);
    static void drawArrays(GLenum mode, GLint first, GLsizei count);
    static void setViewport(GLint x, GLint y, GLsizei width, GLsizei height);
    static void enable(GLenum capability);
    static void disable(GLenum capability);
    static void useProgram(GLuint program);
    static void bindTexture(GLenum target, GLuint texture);
    static void setUniform1f(GLuint location, float v0);
    static void setUniformMatrix4fv(GLuint location, GLsizei count, GLboolean transpose, const GLfloat *value);
};

#endif // GL_WRAPPER_H