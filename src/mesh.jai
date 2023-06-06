// Everett
// Mesh
// Alex Hartford
// June 2023

Vertex :: struct
{
	position : Vector3;
	normal   : Vector3;
	// We can have at most 4 weights, but they have to sum up
	// to 1, so the last one can be calculated and we don't store it.
	weights  : Vector3;
	joints   : [4]s16;
}

Skinned_Mesh :: struct
{
	#as using skeleton : Skeleton;
	vertices : []Vertex;
	indices  : []u32;
	vao, vbo, ibo : GLuint;
}

MAX_WEIGHTS :: 4;
MAX_JOINTS :: 1000;
#assert MAX_JOINTS <= 0x7fff "MAX_JOINTS can't exceed the max of an s16, since we use that for joint ids.";

Skeleton :: struct
{
	Joint :: struct
	{
		id : s16;
		// This is the matrix of the joint in the rest position,
		// relative to the parent's coordinate system
		local_bind_transform : Matrix4;
		// This is the inverse of the matrix of the joint in model space.
		// Why we have this matrix is explained in anim.jai:generate_skinning_matrices
		inverse_bind_transform : Matrix4;
		parent : *Joint;
	}

	name_to_joint_id : Table (string, s16);
	joints : [] Joint;	// Root joint is joints[0]
}

load_mesh_from_file :: (mesh : *Skinned_Mesh, filename : string) -> bool
{
	parse_joint :: (handler : *Text_File_Handler, mesh : *Skinned_Mesh, joint : *Skeleton.Joint) -> bool
	{
		name, ok := consume_next_line (handler);
		if !ok
			return false;
		joint.id = cast (s16) (joint - mesh.joints.data);
		table_add (*mesh.name_to_joint_id, copy_string (name), joint.id);
		joint.local_bind_transform, ok = parse_matrix4 (handler);

		// Parse parent id
		parent_id : s16;
		parent_id, ok = parse_int (handler, s16);
		if !ok
			return false;
		// Set the inverse bind transform to the model space transform first.
		// We will invert the matrices after all the joints have been parsed.
		if parent_id >= 0
		{
			if parent_id >= mesh.joints.count
  			    return error_out (handler, "Invalid parent joint id.");
            parent := *mesh.joints[parent_id];
			joint.parent = parent;
			joint.inverse_bind_transform = parent.inverse_bind_transform * joint.local_bind_transform;
		} else {
			joint.parent = null;
			joint.inverse_bind_transform = joint.local_bind_transform;
		}

		return true;
	}

	parse_vertex :: (handler : *Text_File_Handler, mesh : *Skinned_Mesh, vertex : *Vertex) -> bool
	{
		ok : bool;
		vertex.position, ok = parse_vector3 (handler);
		if !ok
			return false;
		vertex.normal, ok = parse_vector3 (handler);
		if !ok
			return false;
		vertex.weights, ok = parse_vector3 (handler);
		if !ok
			return false;
		vertex.joints, ok = parse_int_tuple (handler, 4, s16);
		if !ok
			return false;

		return true;
	}

	parse_triangle :: (handler : *Text_File_Handler, mesh : *Skinned_Mesh, index : s64) -> bool
	{
		tri, ok := parse_int_tuple (handler, 3, u32);
		if !ok
			return false;
		mesh.indices[index + 0] = tri[0];
		mesh.indices[index + 1] = tri[1];
		mesh.indices[index + 2] = tri[2];
		return true;
	}

	handler : Text_File_Handler;
	defer deinit (*handler);

	found_slash, dir, basename := split_from_right (filename, #char "/");
	if !found_slash then basename = filename;
	start_file (*handler, basename, filename, optional = false);
	if handler.failed
		return false;

	if handler.version != 1
		return error_out (handler, "Invalid version number.");

	ok : bool;
	mesh.joints.count, ok = parse_ident_and_int_line (*handler, "joint_count");
	if !ok
		return false;
	if mesh.joints.count > MAX_JOINTS
		return error_out (handler, "Too many joints (expected at most %, got %).", MAX_JOINTS, mesh.joints.count);

	mesh.vertices.count, ok = parse_ident_and_int_line (*handler, "vertex_count");
	if !ok
		return false;

	triangle_count : s64;
	triangle_count, ok = parse_ident_and_int_line (*handler, "triangle_count");
	if !ok
		return false;
	mesh.indices.count = triangle_count * 3;

	// Allocate all the data in one batch, so everything is contiguous
	all_data := alloc (size_of (Skeleton.Joint) * mesh.joints.count
		+ size_of (Vertex) * mesh.vertices.count
		+ size_of (u32) * mesh.indices.count
	);

	init (*mesh.name_to_joint_id, mesh.joints.count);
	mesh.joints.data   = all_data;
	mesh.vertices.data = cast (*Vertex) (mesh.joints.data + mesh.joints.count);
	mesh.indices.data  = cast (*u32) (mesh.vertices.data + mesh.vertices.count);
	
	// Parse joints
	line, found := consume_next_line (*handler);
	if line != "joints:"
		return error_out (handler, "Expected 'joints:', got '%' instead.", line);
	for * mesh.joints
		if !parse_joint (*handler, mesh, it)
			return error_out (handler, "Could not parse joint %.", it_index);
	// Inverse all the bind transforms we calculated while parsing the joints
	for * mesh.joints
		it.inverse_bind_transform = inverse (it.inverse_bind_transform);

	// Parse vertices
	line, found = consume_next_line (*handler);
	if line != "vertices:"
		return error_out (handler, "Expected 'vertices:', got '%' instead.", line);
	for * mesh.vertices
		if !parse_vertex (*handler, mesh, it)
			return error_out (handler, "Could not parse vertex %.", it_index);

	// Parse triangles
	line, found = consume_next_line (*handler);
	if line != "triangles:"
		return error_out (handler, "Expected 'triangles:', got '%' instead.", line);
	for i : 0..triangle_count - 1
		if !parse_triangle (*handler, mesh, i * 3)
			return error_out (handler, "Could not parse triangle %.", i);

	line, found = consume_next_line (*handler);
	if found
		return error_out (handler, "Expected EOF.");

	return true;
}

// =============================================================================
// OpenGL

init_mesh_rendering_objects :: (using mesh : *Skinned_Mesh)
{
    // We need a vertex buffer, that holds all our vertices, and an index
    // buffer, that holds all of our indices. We also need a vertex array, that
    // holds the information of the layout of our vertex buffer.
	glGenVertexArrays(1, *vao);
	glGenBuffers(1, *vbo);
	glGenBuffers(1, *ibo);
	glBindVertexArray(vao);
	defer glBindVertexArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	defer glBindBuffer (GL_ARRAY_BUFFER, 0);
	glBufferData(GL_ARRAY_BUFFER, size_of(Vertex) * vertices.count, vertices.data, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
	defer glBindBuffer (GL_ELEMENT_ARRAY_BUFFER, 0);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, size_of(u32) * indices.count, indices.data, GL_STATIC_DRAW);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)0);
	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)size_of(Vector3));
	glEnableVertexAttribArray(2);
	glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)(2 * size_of(Vector3)));
	glEnableVertexAttribArray(3);
	glVertexAttribIPointer(3, 4, GL_SHORT, size_of(Vertex), cast(*void) (3 * size_of(Vector3)));
}

