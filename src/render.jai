// Everett
// Render
// Alex Hartford
// June 2023

render :: (mesh : Skinned_Mesh, basic_shader : Shader)
{
    glViewport(0, 0, xx window_width, xx window_height);
    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    use_shader(basic_shader);
    {
        set_mat4(basic_shader, "projection", camera.projection_matrix);
        set_mat4(basic_shader, "view", camera.view_matrix);

        set_vec4(basic_shader, "color", Vector4.{1.0, 0.3, 0.2, 1.0});

        model := Matrix4_Identity;
        set_mat4(basic_shader, "model", model);

        draw_mesh(mesh, Matrix4_Identity, .[]);
    }
    glUseProgram(0);

    SDL_GL_SwapWindow(window);
}

draw_mesh :: (using mesh : Skinned_Mesh, model_matrix : Matrix4, skinning_matrices : []Matrix4)
{
	assert (skinning_matrices.count <= MAX_JOINTS, "Skinning matrices array cannot have more than % elements for now.");

    /*
	// Fill the uniform buffer with the skinning data
	glBindBuffer (GL_UNIFORM_BUFFER, g_big_data_ubo);
	glBufferSubData (GL_UNIFORM_BUFFER, 0, size_of (Matrix4) * skinning_matrices.count, skinning_matrices.data);
	glBindBuffer (GL_UNIFORM_BUFFER, 0);
    */

	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

	glDrawElements(GL_TRIANGLES, cast(u32)indices.count, GL_UNSIGNED_INT, null);
}

