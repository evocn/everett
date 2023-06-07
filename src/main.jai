// Everett
// Main
// Alex Hartford
// June 2023

window : *SDL_Window;
gl_context : *SDL_GLContext;

window_width  : s32 = 900;
window_height : s32 = 600;

running : bool;

//
//

camera : Camera;

//
//

settings : struct {
    control_camera := true;
    line_mode := false;
}

//
//

main :: () {
    init_result := init();
    assert(init_result);

    mesh : Skinned_Mesh;
    loaded := load_mesh_from_file(*mesh, "assets/meshes/mannequin.mesh");
    if loaded
        init_mesh_rendering_objects(*mesh);
    else
        log_error("Could not load mesh %.", basename);

    line : Line;
    array_add(*line.points, xyz(0, 0, 0));
    array_add(*line.points, xyz(1, 0, 0));
    array_add(*line.points, xyz(2, 0, 0));
    array_add(*line.points, xyz(3, 0, 0));
    init_line_rendering_objects(*line);

    targets : Line;
    array_add(*targets.points, xyz(0, 0, 1));
    array_add(*targets.points, xyz(0, -2, 0));
    array_add(*targets.points, xyz(-2.9, 0, 0));
    array_add(*targets.points, xyz(1, 1, 1));
    init_line_rendering_objects(*targets);

    // Shaders
    basic_shader := make_shader("basic.vs", "basic.fs");
    animation_shader := make_shader("anim.vs", "main.fs");

    interp_factor : float;
    targeting_index := 0;
    current_line : Line;
    solved : bool;
    initial_zero_position := line.points[0];

    dt, last_frame := 0.0;
    running = true;
    while running {
        cur_time := cast(float32)get_time();
        dt = cur_time - last_frame;
        last_frame = cur_time;

        // Handle Events
        handle_events();
        update_flying_camera(*camera, dt);

        // Simulate
        interp_factor += dt * 0.5;

        possible : bool;
        while !possible {
            using line;
            maximum_line_length : float;
            for i : 1..points.count-1 {
                maximum_line_length += length(points[i] - points[i-1]);
            }

            if maximum_line_length < length(points[0] - targets.points[targeting_index]) {
                print("Skipping unreachable index %. Maximum length the arm could reach was %, while the point was % away.\n", 
                      targeting_index, maximum_line_length, length(points[0] - targets.points[targeting_index]));
                targeting_index += 1;
                if targeting_index >= targets.points.count targeting_index = 0;
            }
            else {
                possible = true;
            }
        }

        if !solved {
            forward : bool;

            array_copy(*current_line.points, line.points);

            iteration := 0;
            print("Target: %\n", targets.points[targeting_index]);
            while !solved {
                iteration += 1;
                print("Iteration %\n", iteration);
                if forward
                    solved = forward_inverse_kinematics(*current_line, targets.points[targeting_index]);
                else
                    solved = backward_inverse_kinematics(*current_line, targets.points[targeting_index]);
                forward = !forward;
            }
        }

        for i : 0..line.points.count-1 {
            line.points[i] = line.points[i] * (1.0 - interp_factor) + current_line.points[i] * interp_factor;
        }

        if interp_factor >= 1 {
            interp_factor = 0.0;

            array_copy(*line.points, current_line.points);
            line.points[0] = initial_zero_position;

            targeting_index += 1;
            if targeting_index >= targets.points.count targeting_index = 0;
            solved = false;
        }

        // Render
        render(mesh, line, targets, animation_shader, basic_shader);

        SDL_Delay(1);
    }

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
#import "SDL";
#import "GL";
