// Everett
// Input
// Alex Hartford
// June 2023

input : struct {
    w := false;
    a := false;
    s := false;
    d := false;
    q := false;
    e := false;

    shift := false;
}

handle_events :: () {
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        ImGui_ImplSdl_ProcessEvent(*event);
        if event.type == {
            case SDL_QUIT;
                running = false;
            case SDL_KEYUP;
                // Editor Inputs
                if event.key.keysym.sym == SDLK_w input.w = false;
                if event.key.keysym.sym == SDLK_a input.a = false;
                if event.key.keysym.sym == SDLK_s input.s = false;
                if event.key.keysym.sym == SDLK_d input.d = false;
                if event.key.keysym.sym == SDLK_q input.q = false;
                if event.key.keysym.sym == SDLK_e input.e = false;
                if event.key.keysym.sym == SDLK_LSHIFT input.shift = false;

            case SDL_KEYDOWN;
                if event.key.keysym.sym == SDLK_ESCAPE running = false;

                // Settings
                if event.key.keysym.sym == SDLK_l {
                    if settings.line_mode
                        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
                    else
                        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
                    settings.line_mode = !settings.line_mode;
                }

                // Editor Inputs
                if event.key.keysym.sym == SDLK_r {
                    if program_state.mode == .GAME {
                        program_state.mode = .EDITOR;
                        program_state.control_camera_looking = false;
                    }
                    else {
                        program_state.mode = .GAME;
                        program_state.control_camera_looking = true;
                    }
                }

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

