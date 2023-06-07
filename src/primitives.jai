// Everett
// Line
// Alex Hartford
// June 2023


// OpenGL Lines
//

// @NOTE: These lines cannot add more members after being initialized.
// @TODO: Create a more robust solution.
Line :: struct {
    points: [..] Vector3;

    vao, vbo : GLuint;
}

forward_inverse_kinematics :: (using line: *Line, target : Vector3, distance_threshold := 0.0001) -> bool {
    distances : [..] float;
    for i : 0..points.count-2 array_add(*distances, distance(points[i], points[i+1]));

    for i : 0..points.count-2 {
        direction := normalize(points[i+1] - points[i]);
        points[i+1] = points[i] + direction * distances[i];
    }

    if distance(points[points.count-1], target) <= distance_threshold
        return true;
    else
        return false;
}

backward_inverse_kinematics :: (using line: *Line, target : Vector3, distance_threshold := 0.0001) -> bool {
    distances : [..] float;
    for i : 0..points.count-2 array_add(*distances, distance(points[i], points[i+1]));

    initial_point_zero := points[0];
    points[points.count-1] = target;

    for < i : points.count-1..1 {
        direction := normalize(points[i-1] - points[i]);
        points[i-1] = points[i] + direction * distances[i-1];
    }

    if distance(points[0], initial_point_zero) <= distance_threshold
        return true;
    else
        return false;
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
