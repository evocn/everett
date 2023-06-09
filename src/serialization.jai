// Everett
// Serialization
// Alex Hartford
// June 2023

SERIALIZATION_VERSION :: 1;
serialization_path :: "data/levels";

save_level :: (entities : [..] *Entity, filename : string) {
    print("Saving %\n", filename);
    serialized := serialize(entities);
    write_entire_file(tprint("%/%", serialization_path, filename), serialized);
}

load_level :: (entities: *[..] *Entity, meshes : Table(string, *Skinned_Mesh), filename : string) {
    print("Loading %\n", filename);
    success := deserialize(entities, meshes, tprint("%/%", serialization_path, "level1.entities"));
    assert(success, "Unable to load file %\n", filename);
}

//
//

#scope_file

serialize :: (entities : [..] *Entity) -> string {
    builder: String_Builder;
	defer free_buffers(*builder);

    init_string_builder(*builder);
    print_to_builder(*builder, "[%] # Version Number\n\n", SERIALIZATION_VERSION);
    print_to_builder(*builder, "% # Number of Entities\n\n", entities.count);
    for entities {
        print_to_builder(*builder, "%\n", it.name);
        print_to_builder(*builder, "%\n", cast(int)it.kind);
        print_to_builder(*builder, "%\n", it.position);
        print_to_builder(*builder, "%\n", it.orientation);
        print_to_builder(*builder, "%\n", it.scale);
        print_to_builder(*builder, "%\n", it.mesh_name);
    }

    return builder_to_string(*builder);
}

deserialize :: (entities: *[..] *Entity, meshes : Table(string, *Skinned_Mesh), filename : string) -> bool {
    array_reset(entities);

	handler : Text_File_Handler;
	defer deinit(*handler);

	found_slash, dir, basename := split_from_right(filename, #char "/");
	if !found_slash then basename = filename;
	start_file(*handler, basename, filename, optional = false);
	if handler.failed return false;

	if handler.version != SERIALIZATION_VERSION
		return error_out(handler, "Invalid version number.");

	line, found := consume_next_line(*handler);
    number_of_entities := string_to_int(line);

    ok : bool;
    for i : 0..number_of_entities-1 {
        new_entity := New(Entity);
        new_entity.name,        ok = parse_string(*handler);
        kind : int;
        kind,                   ok = parse_int(*handler);
        new_entity.kind = cast(Entity_Kind)kind;
        new_entity.position,    ok = parse_vector3(*handler);
        new_entity.orientation, ok = parse_quaternion(*handler);
        new_entity.scale,       ok = parse_float(*handler);
        new_entity.mesh_name,   ok = parse_string(*handler);

        array_add(entities, new_entity);
    }

    for <<entities {
        found_mesh : bool;
        it.mesh, found_mesh = table_find(*meshes, it.mesh_name);
        if !found_mesh
            log_error("Mesh not found: %.", it.mesh_name);
    }

    return true;
}

