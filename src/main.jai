// Everett
// Main
// Alex Hartford
// June 2023

window : *SDL_Window;
gl_context : *SDL_GLContext;
running : bool;

camera : Camera;

window_width  : s32 = 640;
window_height : s32 = 480;

main :: () {
    init_result := init();
    assert(init_result);

    mesh : Skinned_Mesh;
    loaded := load_mesh_from_file(*mesh, "assets/meshes/mannequin.mesh");
    if loaded
        init_mesh_rendering_objects(*mesh);
    else
        log_error("Could not load mesh %.", basename);

    // Shaders
    basic_shader := make_shader("basic.vs", "basic.fs");

    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    dt, last_frame := 0.0;
    running = true;
    while running {
        cur_time := cast(float32)get_time();
        dt = cur_time - last_frame;
        last_frame = cur_time;

        handle_events();
        update_flying_camera(*camera, dt);

        render(mesh, basic_shader);

        SDL_Delay(1);
    }

    SDL_DestroyWindow(window);
    SDL_Quit();

    handle_events :: () {
        event : SDL_Event;
        while SDL_PollEvent(*event) {
            if event.type == {
                case SDL_QUIT;
                    running = false;
                case SDL_KEYUP;
                    if event.key.keysym.sym == SDLK_ESCAPE running = false;

                    if event.key.keysym.sym == SDLK_w input.w = false;
                    if event.key.keysym.sym == SDLK_a input.a = false;
                    if event.key.keysym.sym == SDLK_s input.s = false;
                    if event.key.keysym.sym == SDLK_d input.d = false;
                    if event.key.keysym.sym == SDLK_q input.q = false;
                    if event.key.keysym.sym == SDLK_e input.e = false;

                    if event.key.keysym.sym == SDLK_LSHIFT input.shift = false;
                case SDL_KEYDOWN;
                    if event.key.keysym.sym == SDLK_w input.w = true;
                    if event.key.keysym.sym == SDLK_a input.a = true;
                    if event.key.keysym.sym == SDLK_s input.s = true;
                    if event.key.keysym.sym == SDLK_d input.d = true;
                    if event.key.keysym.sym == SDLK_q input.q = true;
                    if event.key.keysym.sym == SDLK_e input.e = true;

                    if event.key.keysym.sym == SDLK_LSHIFT input.shift = true;
                case SDL_WINDOWEVENT;
                    if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
                        window_width  = event.window.data1;
                        window_height = event.window.data2;
                    }
            }
        }
    }
}

Input :: struct {
    w := false;
    a := false;
    s := false;
    d := false;
    q := false;
    e := false;

    shift := false;
}
input : Input;

#import "Basic";
#import "String";
#import "File";
#import "File_Utilities";
#import "System";
#import "Math";
#import "Hash_Table";
#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
