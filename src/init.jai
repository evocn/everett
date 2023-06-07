// Everett
// Init
// Alex Hartford
// June 2023

init :: () -> bool {
    SDL_Init(SDL_INIT_VIDEO);

    // Create an application window with the following settings:
    window = SDL_CreateWindow("Everett",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, window_width, window_height,
        SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN|SDL_WINDOW_INPUT_GRABBED);

    if !window {
        print("Could not create window: %\n", to_string(SDL_GetError()));
        return false;
    }

    // SDL Settings
    SDL_ShowCursor(0);
    SDL_SetRelativeMouseMode(SDL_TRUE);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);

    gl_context = SDL_GL_CreateContext(window);
    if !gl_context {
        print( "Could not create OpenGL context: %\n", to_string(SDL_GetError()));
        return false;
    }  

    gl_load(*gl, SDL_GL_GetProcAddress);
    using gl;

    //print("GL Vendor = %\n", to_string(glGetString(GL_VENDOR)));
    //print("GL Version = %\n", to_string(glGetString(GL_VERSION)));

    // GL Settings
    glEnable(GL_DEPTH_TEST); 
    glLineWidth(10);
    glPointSize(10);

	// Set the working directory to the base of the project so we can access our folders nicely.
	executable_path := path_strip_filename(get_path_of_running_executable());
	set_working_directory (tprint("%/../", executable_path));

    return true;
}
