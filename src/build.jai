// Everett
// Build
// Alex Hartford
// May 2023

build :: () {
    w := compiler_create_workspace("Everett Workspace");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    options := get_build_options(w);
    options.output_executable_name = "everett";

    // NOTE(alex): this refers to a relative path from this (build.jai) file.
    options.output_path = "../bin";
    options.output_type = .EXECUTABLE;
    options.text_output_flags = 2;

    set_build_options(options, w);
    set_build_options_dc(.{do_output=false});

	compiler_begin_intercept(w);

    add_build_file(tprint("%/main.jai", #filepath), w);
    add_build_file(tprint("%/utils.jai", #filepath), w);

    add_build_file(tprint("%/init.jai", #filepath), w);
    add_build_file(tprint("%/imgui_init.jai", #filepath), w);
    add_build_file(tprint("%/editor.jai", #filepath), w);
    add_build_file(tprint("%/input.jai", #filepath), w);
    add_build_file(tprint("%/camera.jai", #filepath), w);
    //add_build_file(tprint("%/inspector.jai", #filepath), w);

    add_build_file(tprint("%/grid.jai", #filepath), w);
    add_build_file(tprint("%/cursor.jai", #filepath), w);
    add_build_file(tprint("%/unit.jai", #filepath), w);
    add_build_file(tprint("%/serialization.jai", #filepath), w);

    add_build_file(tprint("%/mesh.jai", #filepath), w);
    add_build_file(tprint("%/animation.jai", #filepath), w);
    add_build_file(tprint("%/primitives.jai", #filepath), w);
    add_build_file(tprint("%/parse_utils.jai", #filepath), w);
    add_build_file(tprint("%/load_obj.jai", #filepath), w);

    add_build_file(tprint("%/render.jai", #filepath), w);
    add_build_file(tprint("%/color.jai", #filepath), w);
    add_build_file(tprint("%/light.jai", #filepath), w);

    add_build_file(tprint("%/shader.jai", #filepath), w);

	// Set up ctags options
	ctags: CTags;
	ctags.base_path = get_working_directory();
	defer reset(*ctags);

	while true {
		message := compiler_wait_for_message();
		if !message continue;

		if message.workspace == w {
			process_message(*ctags, message);
		}

		if message.kind == .COMPLETE break;
	}
}

#run build();


#import "Basic";
#import "Compiler";
#import "ctags";
