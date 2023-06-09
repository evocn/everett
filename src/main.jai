// Everett
// Main
// Alex Hartford
// June 2023

window : *SDL_Window;
gl_context : *SDL_GLContext;

window_width  : s32 = 1080;
window_height : s32 = 600;

running : bool;

//
//

camera : Camera;

//
//

program_state : struct {
    Program_Mode :: enum {
        GAME;
        EDITOR;
    }
    mode : Program_Mode;

    current_level_name := "level1.entities";

    control_camera_movement := true;
    control_camera_looking  := true;
    // @TODO: The cool thing from the other engine where you control the camera in editor mode by right-clicking (or maybe mouse wheel click?)

    imgui_capturing_mouse    := false;
    imgui_capturing_keyboard := false;

    framerate : float;
}

editor : struct {
    selected_entity := -1;
    selected_mesh := "";
}

settings : struct {
    autosave  := true;
    line_mode := false;
}

//
//

main :: () {
    print("Booting up...\n");
    defer print("Program exited successfully.\n");

    init_result := init();
    assert(init_result);

    imgui_context := ImGui.CreateContext();

    // Shaders
    basic_shader     := make_shader("basic.vs", "basic.fs");
    texture_shader   := make_shader("texture.vs", "basic.fs");
    animation_shader := make_shader("anim.vs", "main.fs");

    // Meshes
    // @TODO: This should be a bucket array.
    meshes : Table(string, *Skinned_Mesh);
    table_add(*meshes, "mesh_bird", new_skinned_mesh("bird.mesh"));
    table_add(*meshes, "mesh_cube", new_skinned_mesh("cube.mesh"));
    table_add(*meshes, "mesh_mannequin", new_skinned_mesh("mannequin.mesh"));

    /*
    // Animations
    anim : Sampled_Animation;
    loaded = load_animation_from_file(*anim, "assets/animations/idle.anim");
    if !loaded
        log_error ("Could not load % animation.", basename);

    init_rendering_objects(animation_shader);

    animation_time := 0.0;
    animation_speed_in_fps := 20.0;

    pose : Skeleton_Pose;
    pose = make_pose_for_skeleton(*mesh.skeleton);
    */

    // Entities
    entities : [..] *Entity;

    print("Welcome to the Everett Engine.\n");

    load_level(*entities, meshes, program_state.current_level_name);

    autosave_interval := 60.0; // seconds
    next_autosave     := autosave_interval;

    dt, last_frame := 0.0;
    running = true;
    while running {
		reset_temporary_storage();
        current_time := cast(float32)get_time();
        dt = current_time - last_frame;
        last_frame = current_time;

        // Autosave
        if settings.autosave {
            if(current_time > next_autosave) {
                save_level(entities, program_state.current_level_name);
                print("Autosaving...\n");
                next_autosave = next_autosave + autosave_interval;
            }
        }

        // Handle Events
        handle_events();
        update_flying_camera(*camera, dt);

        // Simulate
        /*
        reset_to_bind_pose(*pose);
        sample_animation(anim, animation_time, *pose, .LINEAR);

        // Increment animation time
        animation_time += dt * animation_speed_in_fps;
        animation_time = fmod_cycling(animation_time, xx anim.sample_count);

        // We transpose the result because OpenGL stores matrices in column-major
        generate_skinning_matrices(*pose, transpose_result = true);
        */

        if program_state.mode == .EDITOR {
            update_and_draw_editor(*entities, meshes);
        }

        // Render
        render(entities, animation_shader, texture_shader);
        if program_state.mode == .EDITOR {
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        }
        SDL_GL_SwapWindow(window);

        SDL_Delay(1);
    }

    ImGui_ImplSdl_Shutdown();
    ImGui.DestroyContext(imgui_context);
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

#import "Basic";
#import "String";
#import "File";
#import "File_Utilities";
#import "Text_File_Handler";
#import "System";
#import "Math";
#import "Hash_Table";
#import "Hash";
Reflection :: #import "Reflection";

#import "SDL";
ImGui :: #import "ImGui";
#import "GL";
