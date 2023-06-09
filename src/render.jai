// Everett
// Render
// Alex Hartford
// June 2023

render :: (entities : [..] *Entity, shader : Shader, basic_shader : Shader)
{
    glViewport(0, 0, xx window_width, xx window_height);
    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    {
        use_shader(shader);
        defer disable_shaders();
        set_mat4(shader, "projection", camera.projection_matrix);
        set_mat4(shader, "view", camera.view_matrix);

        set_vec4(shader, "color", Vector4.{1.0, 0.3, 0.2, 1.0});

        for entities {
            model := make_scale_matrix4(Vector3.{it.scale, it.scale, it.scale});
            model = rotate(model,    it.orientation);
            model = translate(model, it.position);
            set_mat4(shader, "model", model);

            draw_skinned_mesh(it.mesh, .[]);
        }

        // @TODO: This is such a hassle just to draw the selected entity highlighted...
        if editor.selected_entity != -1 {
            using entities[editor.selected_entity];

            model := make_scale_matrix4(Vector3.{scale, scale, scale});
            model = rotate(model,    orientation);
            model = translate(model, position);
            set_mat4(shader, "model", model);

            set_float(shader, "highlight", sin(cast(float32)get_time()));

            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            draw_skinned_mesh(mesh, .[]);

            // Set the Line Mode back to what it was before.
            if settings.line_mode
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            else
                glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

            set_float(shader, "highlight", 0.0);
        }
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
