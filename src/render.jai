// Everett
// Render
// Alex Hartford
// June 2023

render :: (map : Map, units : [..] *Unit)
{
    glViewport(0, 0, xx window_width, xx window_height);
    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // Draw Game Board
    {
        shader := render_context.animation_shader;
        use_shader(shader);
        defer disable_shaders();

        set_mat4(shader, "projection", camera.projection_matrix);
        set_mat4(shader, "view", camera.view_matrix);

        set_vec4(shader, "color", orange);
        set_vec3(shader, "light_direction", render_context.directional_light.direction);
        set_vec3(shader, "light_color", render_context.directional_light.color);

        // Draw Grid
        draw_tiles(map, shader);

        // Draw Highlighted Grid Square

        // Draw Units
        for units {
            draw_unit(it, shader);
        }
        // Draw Selected Unit
        if editor.selected_unit != -1 {
            draw_selected_unit(units[editor.selected_unit], shader);
        }

        // Draw Cursor
        draw_cursor(shader);
    }

    // Draw Overlays
    {
        shader := render_context.basic_shader;
        use_shader(shader);
        defer disable_shaders();

        set_mat4(shader, "projection", camera.projection_matrix);
        set_mat4(shader, "view", camera.view_matrix);

        draw_squares_overlay(shader, cursor.accessible);
        draw_squares_overlay(shader, cursor.interactible, color = red);
        draw_square_overlay(shader, cursor.square, color = blue, alpha = 0.8, height_above_stage = 0.1);
    }

    // Draw Skybox
    {
        shader := render_context.skybox_shader;
        use_shader(shader);
        defer disable_shaders();

        set_mat4(shader, "projection", camera.projection_matrix);
        view_matrix_without_translation := make_matrix4(make_matrix3(camera.view_matrix));
        set_mat4(shader, "view", view_matrix_without_translation);
        set_mat4(shader, "model", Matrix4_Identity);

        draw_skybox(shader);
    }

    // Draw UI Elements
    {
        shader := render_context.screen_shader;
        use_shader(shader);
        defer disable_shaders();

        if whose_turn() == {
            case .NONE;  set_vec4(shader, "color", black);
            case .BLUE;  set_vec4(shader, "color", blue);
            case .RED;   set_vec4(shader, "color", red);
            case .GREEN; set_vec4(shader, "color", green);
        }

        bind(texture, 0);
        orthographic := orthographic_projection_matrix(0, 10.0, 0, 10.0, -1, 1);
        set_mat4(shader, "projection", orthographic);

        /*
        // The API I would love to have:
        size := Vector2.{1.0, 1.0};
        position := Vector2.{0.5, 0.5};

        // The Problem: It draws from the fucking center...

        scale := make_scale_matrix4(Vector3.{size.x, size.y, 1});
        translation := make_translation_matrix4(Vector3.{position.x, position.y, 0});
        model := translation * scale;
        set_mat4(shader, "model", model);
        */

        set_mat4(shader, "model", Matrix4_Identity);

        draw_quad();
    }

    {
        shader := render_context.text_shader;
        use_shader(shader);
        defer disable_shaders();

        orthographic := orthographic_projection_matrix(0, xx window_width, 0, xx window_height, -1, 1);
        set_mat4(shader, "projection", orthographic);

        font, found := table_find(*fonts, "Header");
        draw_text(shader, font, "Hello, Sailor!", 200, 500, 1.0);
    }
}

//
//
//GL_BIG_DATA_UNIFORM_BINDING :: 0;
//g_big_data_ubo : GLuint;

draw_skinned_mesh :: (using mesh : Skinned_Mesh, skinning_matrices : []Matrix4)
{
	assert(skinning_matrices.count <= MAX_JOINTS, "Skinning matrices array cannot have more than % elements for now.");

	// Fill the uniform buffer with the skinning data
	glBindVertexArray(vao);
    /*
	glBindBuffer(GL_UNIFORM_BUFFER, g_big_data_ubo);
	glBufferSubData(GL_UNIFORM_BUFFER, 0, size_of(Matrix4) * skinning_matrices.count, skinning_matrices.data);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
    */

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

	glDrawElements(GL_TRIANGLES, cast(u32)indices.count, GL_UNSIGNED_INT, null);
}

draw_selected_unit :: (using unit : *Unit, shader : Shader) {
    oscillating := sin(cast(float32)get_time());
    set_float(shader, "highlight", oscillating);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    draw_unit(unit, shader);

    // Set the Line Mode back to what it was before.
    if settings.line_mode
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    else
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    set_float(shader, "highlight", 0.0);
}

draw_tiles :: (using map : Map, shader : Shader) {
    cube_mesh, found_mesh := table_find(*meshes, "mesh_cube");
    if !found_mesh {
        log_error("Cube Mesh for tiles not found.\n");
        return;
    }

    for col : 0..grid_width-1 {
        for row : 0..grid_height-1 {
            using tile := map.grid[col][row];
            if tile_kind == {
                case .PLAIN;
                set_vec4(shader, "color", white);

                case .HOLE;
                continue;
                //set_vec4(shader, "color", black);

                case .FOREST;
                set_vec4(shader, "color", green);

                case;
                set_vec4(shader, "color", white);
            }

            square := Square.{col, row};

            position := get_world_space_center_of_a_tile(square) - Vector3.{y=1};
            translation := make_translation_matrix4(position);
            model := translation;
            set_mat4(shader, "model", model);

            draw_skinned_mesh(cube_mesh, .[]);
        }
    }
}

draw_unit :: (using unit : Unit, shader : Shader) {
    mesh, found_mesh := table_find(*meshes, mesh_name);
    if !found_mesh {
        log_error("Unit Mesh not found: %.", mesh_name);
        return;
    }

    if team == {
        case .NONE;  set_vec4(shader, "color", black);
        case .BLUE;  set_vec4(shader, "color", blue);
        case .RED;   set_vec4(shader, "color", red);
        case .GREEN; set_vec4(shader, "color", green);
    }

    unit_scale :: 1.5;
    scale := make_scale_matrix4(Vector3.{unit_scale, unit_scale, unit_scale});

    orientation : Quaternion;
    if direction == {
        case .NORTH; set_from_axis_and_angle(*orientation, 0, 1, 0, PI);
        case .SOUTH; set_from_axis_and_angle(*orientation, 0, 1, 0, 0);
        case .EAST;  set_from_axis_and_angle(*orientation, 0, 1, 0, PI * 0.5);
        case .WEST;  set_from_axis_and_angle(*orientation, 0, 1, 0, -PI * 0.5);
    }
    rotation := rotation_matrix(Matrix4, orientation);

    position := get_world_space_center_of_a_tile(square);
    translation := make_translation_matrix4(position);
    model := translation * rotation * scale;
    set_mat4(shader, "model", model);

    draw_skinned_mesh(mesh, .[]);
}

get_world_space_center_of_a_tile :: (using square : Square) -> Vector3 {
    return Vector3.{(2.0 * col) - grid_width + 0.5, 0.0, (2.0 * row) - grid_height + 0.5};
}

draw_squares_overlay :: (shader : Shader, squares : [..] Square, color := green, alpha := 0.5, height_above_stage := 0.05) {
    set_vec4(shader, "color", color - Vector4.{0, 0, 0, 1 - alpha});

    for squares {
        position := get_world_space_center_of_a_tile(it);
        translation := make_translation_matrix4(position + Vector3.{y=height_above_stage});

        orientation : Quaternion;
        set_from_axis_and_angle(*orientation, 1, 0, 0, PI * 0.5);
        rotation := rotation_matrix(Matrix4, orientation);

        model := translation * rotation;

        set_mat4(shader, "model", model);
        draw_quad();
    }
}

draw_square_overlay :: (shader : Shader, square : Square, color := green, alpha := 0.5, height_above_stage := 0.05) {
    set_vec4(shader, "color", color - Vector4.{0, 0, 0, 1 - alpha});

    position := get_world_space_center_of_a_tile(square);
    translation := make_translation_matrix4(position + Vector3.{y=height_above_stage});

    orientation : Quaternion;
    set_from_axis_and_angle(*orientation, 1, 0, 0, PI * 0.5);
    rotation := rotation_matrix(Matrix4, orientation);
    model := translation * rotation;

    set_mat4(shader, "model", model);
    draw_quad();
}

//
//

draw_cursor :: (shader: Shader) {
    using cursor;

    // Cursor
    mesh, found_mesh := table_find(*meshes, "mesh_cube");
    if !found_mesh {
        log_error("Mesh for cursor indicator not found.\n");
        return;
    }

    set_vec4(shader, "color", blue);

    cursor_scale :: 0.5;
    scale := make_scale_matrix4(Vector3.{cursor_scale, cursor_scale, cursor_scale});

    rotating    := cast(float32)get_time() * 2;
    oscillating := sin(cast(float32)get_time() * 2) * 0.5;
    orientation : Quaternion;
    set_from_axis_and_angle(*orientation, 0, 1, 0, rotating);
    rotation := rotation_matrix(Matrix4, orientation);

    position := get_world_space_center_of_a_tile(square) + Vector3.{y=3} + Vector3.{y=oscillating};
    translation := make_translation_matrix4(position);
    model := translation * rotation * scale;
    set_mat4(shader, "model", model);

    draw_skinned_mesh(mesh, .[]);
}
