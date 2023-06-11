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
    space := false;
}

handle_events :: () {
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        ImGui_ImplSdl_ProcessEvent(*event);
        if event.type == {
            case SDL_QUIT;
                running = false;
            case SDL_KEYUP;
                if event.key.keysym.sym == SDLK_w input.w = false;
                if event.key.keysym.sym == SDLK_a input.a = false;
                if event.key.keysym.sym == SDLK_s input.s = false;
                if event.key.keysym.sym == SDLK_d input.d = false;
                if event.key.keysym.sym == SDLK_q input.q = false;
                if event.key.keysym.sym == SDLK_e input.e = false;
                if event.key.keysym.sym == SDLK_LSHIFT input.shift = false;
                if event.key.keysym.sym == SDLK_SPACE  input.space = false;

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

                if event.key.keysym.sym == SDLK_0 {
                    program_state.paused = !program_state.paused;
                }

                if event.key.keysym.sym == SDLK_r {
                    if program_state.mode == {
                        case .GAME;
                        program_state.mode = .EDITOR;
                        drive_editor_camera();

                        case .EDITOR;
                        if program_state.camera_mode == {
                            case .EDITOR;
                            program_state.mode = .GAME;
                            drive_gameplay_camera();

                            case .FREE;
                            drive_editor_camera();
                        }
                    }
                }

                if event.key.keysym.sym == SDLK_c {
                    if program_state.mode == {
                        case .GAME;
                        program_state.mode = .EDITOR;
                        drive_free_camera();

                        case .EDITOR;
                        if program_state.camera_mode == {
                            case .FREE;
                            program_state.mode = .GAME;
                            drive_gameplay_camera();

                            case .EDITOR;
                            drive_free_camera();
                        }
                    }
                }

                // Actual Inputs
                if event.key.keysym.sym == SDLK_w input.w = true;
                if event.key.keysym.sym == SDLK_a input.a = true;
                if event.key.keysym.sym == SDLK_s input.s = true;
                if event.key.keysym.sym == SDLK_d input.d = true;
                if event.key.keysym.sym == SDLK_q input.q = true;
                if event.key.keysym.sym == SDLK_e input.e = true;
                if event.key.keysym.sym == SDLK_LSHIFT input.shift = true;
                if event.key.keysym.sym == SDLK_SPACE  input.space = true;


                /*
            case SDL_MOUSEBUTTONDOWN;
                if event.button.button == SDL_BUTTON_RIGHT {

                }

            case SDL_MOUSEBUTTONUP;
                if event.button.button == SDL_BUTTON_LEFT {

                }
                */

            case SDL_WINDOWEVENT;
                if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
                    window_width  = event.window.data1;
                    window_height = event.window.data2;
                }

        }
    }
}
