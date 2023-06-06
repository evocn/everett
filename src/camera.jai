// Everett
// Camera
// Alex Hartford
// June 2023

//@TODO: 
// Move while mouse moving.
// Remove like 20% of the code in here.

Camera :: struct
{
	FLY_SPEED :: 1.0;
	ROTATION_SPEED :: 0.3;
	ROTATION_SMOOTHING :: 0.3;

	position : Vector3;
	euler_angles : Vector3;
	rotation : Quaternion;
	rotation_input : Vector2;
	fov := 60.0;
	transform := Matrix4_Identity;

	view_matrix := Matrix4_Identity;
	projection_matrix := Matrix4_Identity;
}

g_control_camera := true;
update_flying_camera :: (using camera : *Camera, delta_time : float)
{
	mouse_delta : Vector2;
	move_input  : Vector3;
	move_speed  : float;
	if g_control_camera
	{
        mouse_delta_x, mouse_delta_y : s32;
        mouse_button_delta := SDL_GetRelativeMouseState(*mouse_delta_x, *mouse_delta_y);
		mouse_delta = xy(xx mouse_delta_x, xx mouse_delta_y);

		move_speed = FLY_SPEED;
		if input.shift then move_speed *= 10;
		move_speed *= delta_time;
		move_input.x = cast(float)input.d - cast(float)input.a;
		move_input.y = cast(float)input.e - cast(float)input.q;
		move_input.z = cast(float)input.s - cast(float)input.w;
		move_input = rotate(unit_vector(move_input), rotation);
	}
	position += move_input * move_speed;

    // Orientation
	rotation_input = lerp(rotation_input, mouse_delta, ROTATION_SMOOTHING);
	delta := rotation_input * ROTATION_SPEED;
	euler_angles.x += delta.x * PI / 180.0;
	euler_angles.y += delta.y * PI / 180.0;
	euler_angles.y = clamp (euler_angles.y, -80.0  * PI / 180.0, 80.0 * PI / 180.0);
	yaw : Quaternion;
	// I am not sure why I need to invert the axis of rotation...
	set_from_axis_and_angle(*yaw, 0, -1, 0, euler_angles.x);
	pitch : Quaternion;
	set_from_axis_and_angle(*pitch, -1, 0, 0, euler_angles.y);
	rotation = yaw * pitch;

	transform = make_translation_matrix4(position) * rotation_matrix(Matrix4, rotation);
	view_matrix = inverse(transform);
	aspect_ratio := window_width / cast(float)window_height;
	projection_matrix = make_projection_matrix(fov * PI / 180.0, aspect_ratio, 0.1, 1000.0);
}
