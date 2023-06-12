// Everett
// Main
// Alex Hartford
// June 2023

window : *SDL_Window;
gl_context : *SDL_GLContext;

window_width  : s32 = 1080;
window_height : s32 = 600;
aspect_ratio  : float = 1.8;

running : bool;

// @TODO: This should be a bucket array.
meshes : Table(string, *Skinned_Mesh);

// @TODO: We should probably keep primitives like this one that we'll draw a lot in a structure together.
quad : Quad;
cube : Cube;

// I sort of feel like this can be global, no use polluting function arguments
// with something we'll only ever have on of.
// Let's maybe think on this some more though.
skybox : Skybox;

// Program-Level State
//

program_state : struct {
    Program_Mode :: enum {
        GAME;
        EDITOR;
    }
    mode : Program_Mode;

    paused : bool;

    current_level_name := "level1.units";

    Camera_Mode :: enum {
        GAMEPLAY;
        FREE;
        EDITOR;
    }
    camera_mode := Camera_Mode.GAMEPLAY;

    imgui_capturing_mouse    := false;
    imgui_capturing_keyboard := false;

    framerate : float;
}

editor : struct {
    selected_unit := -1;
    selected_mesh := "";
}

settings : struct {
    autosave  := true;
    line_mode := false;

    default_camera_position :: Vector3.{0, 10, 10};
    default_camera_angles   :: Vector3.{0, 1.0, 0};
}

// Render-Level State
//

render_context : struct {
    directional_light : Directional_Light = .{direction = Vector3.{y=-1}};
    using shaders : struct {
        basic_shader     : Shader;
        screen_shader    : Shader;
        texture_shader   : Shader;
        animation_shader : Shader;
        skybox_shader    : Shader;
    }
}

// Game-Level State
//

Team :: enum {
    NONE;
    BLUE;
    RED;
    GREEN;
}

game_state : struct {
    teams : [..] Team;
    current_turn_team_index : int;
}

whose_turn :: () -> Team {
    using game_state;
    return teams[current_turn_team_index];
}

next_turn :: () -> Team {
    using game_state;

    current_turn_team_index += 1;
    if current_turn_team_index > teams.count
        current_turn_team_index = 0;

    return whose_turn();
}

// Main
//

main :: () {
    print("Booting up...\n");
    defer print("Program exited successfully.\n");

    init_result := init();
    assert(init_result);

    imgui_context := ImGui.CreateContext();

    // Shaders
    render_context.basic_shader     = make_shader("basic.vs", "basic.fs");
    render_context.screen_shader    = make_shader("screen.vs", "basic.fs");
    render_context.texture_shader   = make_shader("texture.vs", "basic.fs");
    render_context.animation_shader = make_shader("anim.vs", "main.fs");
    render_context.skybox_shader    = make_shader("skybox.vs", "skybox.fs");

    // Meshes
    table_add(*meshes, "mesh_bird", new_skinned_mesh("bird.mesh"));
    table_add(*meshes, "mesh_cube", new_skinned_mesh("cube.mesh"));
    table_add(*meshes, "mesh_sphere", new_skinned_mesh("sphere.mesh"));
    table_add(*meshes, "mesh_mannequin", new_skinned_mesh("mannequin.mesh"));

    // Primitives
    init_quad_rendering_objects(*quad);
    init_cube_rendering_objects(*cube);

    // Rendering Structures
    // @NOTE: Most of the load time for the engine right now is loading big textures.
    // For that reason, we're running with super low-res textures here. We probably want to do more research
    // Into how to do big textures in the first place. My guess: We don't.
    load_cubemap_textures(*skybox, "512_cartoon_yellow");

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

    // Gameplay structures setup
    map : Map;
    load_grid(*map, "level1.map");

    units : [..] *Unit;
    load_units(*units, program_state.current_level_name);
    for units {
        occupy(*map, it.square, it);
    }

    array_add(*game_state.teams, .BLUE);
    array_add(*game_state.teams, .RED);

    set_camera();

    autosave_interval := 60.0; // seconds
    next_autosave     := autosave_interval;

    print("Welcome to the Everett Engine.\n");

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
                save_units(units, program_state.current_level_name);
                print("Autosaving...\n");
                next_autosave = next_autosave + autosave_interval;
            }
        }

        // Handle Events
        handle_events();
        update_flying_camera(dt);

        // Simulate
        if program_state.mode == .GAME {
            if !program_state.paused {
                update_cursor(*map);
            }
        }

        /*
        reset_to_bind_pose(*pose);
        sample_animation(anim, animation_time, *pose, .LINEAR);

        // Increment animation time
        animation_time += dt * animation_speed_in_fps;
        animation_time = fmod_cycling(animation_time, xx anim.sample_count);

        // We transpose the result because OpenGL stores matrices in column-major
        generate_skinning_matrices(*pose, transpose_result = true);
        */

        // Editor
        if program_state.mode == .EDITOR && program_state.camera_mode == .EDITOR {
            update_and_draw_editor(*units);
        }

        // Render
        render(map, units);
        if program_state.mode == .EDITOR && program_state.camera_mode == .EDITOR {
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

using Basic :: #import "Basic";
#import "String";
#import "System"; // get_path_of_running_executable()
#import "Math";
#import "Hash_Table";
Reflection :: #import "Reflection"; // Inspect()

#import "File";
#import "Text_File_Handler";
#import "stb_image";

#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
