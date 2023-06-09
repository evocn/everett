// Everett
// Primitives
// Alex Hartford
// June 2023



// Lines
//

// @NOTE: These lines cannot add more members after being initialized.
// @TODO: Create a more robust solution.
Line :: struct {
    points: [..] Vector3;
    vao, vbo : GLuint;
}

init_line_rendering_objects :: (using line: *Line)
{
    glGenVertexArrays(1, *vao);
    glGenBuffers(1, *vbo);

    glBindVertexArray(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, points.count * size_of(Vector3), *points[0], GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * size_of(float), cast(*void)0);
}

// This is maybe the slowest way possible to draw a line!
draw_line :: (using line: Line, color: Vector4 = Vector4.{1.0, 1.0, 1.0, 1.0})
{
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferSubData(GL_ARRAY_BUFFER, 0, size_of(Vector3) * points.count, points.data);
	glDrawArrays(GL_LINE_STRIP, 0, xx points.count);
}

draw_points :: (using line: Line, color: Vector4 = Vector4.{1.0, 1.0, 1.0, 1.0})
{
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferSubData(GL_ARRAY_BUFFER, 0, size_of(Vector3) * points.count, points.data);
	glDrawArrays(GL_POINTS, 0, xx points.count);
}
