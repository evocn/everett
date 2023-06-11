// Everett
// Serialization
// Alex Hartford
// June 2023

UNITS_VERSION :: 1;
units_path :: "data/levels";

save_units :: (units : [..] *Unit, filename : string) {
    print("Saving %\n", filename);
    serialized := serialize(units);
    write_entire_file(tprint("%/%", units_path, filename), serialized);
}

load_units :: (units: *[..] *Unit, meshes : Table(string, *Skinned_Mesh), filename : string) {
    print("Loading %\n", filename);
    success := deserialize(units, meshes, tprint("%/%", units_path, filename));
    assert(success, "Unable to load file %\n", filename);
}

//
//

serialize :: (units : [..] *Unit) -> string {
    builder: String_Builder;
	defer free_buffers(*builder);

    init_string_builder(*builder);
    print_to_builder(*builder, "[%] # Version Number\n\n", UNITS_VERSION);
    print_to_builder(*builder, "% # Number of Units\n\n", units.count);
    for units {
        print_to_builder(*builder, "%\n", it.name);
        print_to_builder(*builder, "%\n", cast(int)it.direction);
        print_to_builder(*builder, "%\n", it.square);
        print_to_builder(*builder, "%\n", it.mesh_name);

        print_to_builder(*builder, "\n");
    }

    return builder_to_string(*builder);
}

// @Robustness: We can most certainly do a better job handling bad
// serialization files, most likely by refusing to parse them, and returning no
// entities. This will reduce the chance that we'll autosave or accidentally manual-save a wonky file.
// I want this to be idiot-proof, and for me to never have to worry about giving the engine to a designer.
deserialize :: (units: *[..] *Unit, meshes : Table(string, *Skinned_Mesh), full_path : string) -> bool {
    array_reset(units);

	handler : Text_File_Handler;
	defer deinit(*handler);

	found_slash, dir, basename := split_from_right(full_path, #char "/");
	if !found_slash then basename = full_path;
	start_file(*handler, basename, full_path, optional = false);
	if handler.failed return false;

	if handler.version != UNITS_VERSION
		return error_out(handler, "Invalid version number.");

	line, found := consume_next_line(*handler);
    number_of_units := string_to_int(line);

    ok : bool;
    // @TODO: Make this not rely on the number?
    for i : 0..number_of_units-1 {
        new_unit := New(Unit);
        new_unit.name,      ok = parse_string(*handler);
        direction_tmp : int;
        direction_tmp,      ok = parse_int(*handler);
        new_unit.direction = cast(Direction)direction_tmp;
        new_unit.square,    ok = parse_square(*handler);
        new_unit.mesh_name, ok = parse_string(*handler);

        array_add(units, new_unit);
    }

    for <<units {
        found_mesh : bool;
        it.mesh, found_mesh = table_find(*meshes, it.mesh_name);
        if !found_mesh {
            log_error("Mesh not found: %.", it.mesh_name);
            it.mesh = null;
        }
    }

    return true;
}

//
// Grids
//

GRID_VERSION :: 1;
grids_path :: "data/levels";

save_grid :: (using map : Map, filename : string) {
    print("Saving %\n", filename);
    builder: String_Builder;
	defer free_buffers(*builder);

    init_string_builder(*builder);
    print_to_builder(*builder, "[%] # Version Number\n\n", GRID_VERSION);
    print_to_builder(*builder, "% # Width\n", grid_width);
    print_to_builder(*builder, "% # Height\n\n", grid_height);

    print_grid_to_builder(*builder, grid);

    write_entire_file(tprint("%/%", grids_path, filename), builder_to_string(*builder));
}

load_grid :: (using map : *Map, filename : string) {
    print("Loading %\n", filename);
    success := parse_grid(map, tprint("%/%", grids_path, filename));
    assert(success, "Unable to load file %\n", filename);
}

print_grid_to_builder :: (builder : *String_Builder, grid : [grid_width][grid_height] Tile) {
    for col : 0..grid_width-1 {
        for row : 0..grid_height-1 {
            print_to_builder(builder, "%", cast(int)grid[col][row].tile_kind);
        }
        print_to_builder(builder, "\n");
    }
}

parse_grid :: (using map : *Map, full_path : string) -> bool {
	handler : Text_File_Handler;
	defer deinit(*handler);

	found_slash, dir, basename := split_from_right(full_path, #char "/");
	if !found_slash then basename = full_path;
	start_file(*handler, basename, full_path, optional = false);
	if handler.failed return false;

	if handler.version != UNITS_VERSION
		return error_out(handler, "Invalid version number.");

    found : bool;
    line : string;
	line, found = consume_next_line(*handler);
    file_says_grid_width := string_to_int(line);
	line, found = consume_next_line(*handler);
    file_says_grid_height := string_to_int(line);

    assert(file_says_grid_width == grid_width);
    assert(file_says_grid_height == grid_height);

    for row : 0..grid_height-1 {
        line, found = consume_next_line(*handler);
        for character, col : cast([] u8)line {
            grid[col][row].tile_kind = cast(Tile_Kind)(character - 48);
        }
    }

    return true;
}
