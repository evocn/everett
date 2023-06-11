// Everett
// Entity
// Alex Hartford
// June 2023

// @Example
Bird :: struct {
    #as using entity : Entity;
    kind = .BIRD;
    name = "Bird";
}

Entity_Kind :: enum #complete #specified {
    BIRD :: 1;
}

Entity :: struct {
    name : string;
    kind : Entity_Kind;

    using position : Vector3;
    orientation    : Quaternion;
    scale := 1.0;

    mesh_name : string;
    mesh : *Skinned_Mesh; @NoSerialize //@TODO: HOW DO WE DO THIS?
}

make_entity :: (mesh : *Skinned_Mesh) -> *Entity
{
    new_entity := New(Entity);
    new_entity.mesh = mesh;
    return new_entity;
}

draw_entity :: (using entity : *Entity, shader : Shader) {
    if mesh {
        scale_mat   := make_scale_matrix4(Vector3.{scale, scale, scale});
        rotation    := rotation_matrix(Matrix4, orientation);
        translation := make_translation_matrix4(position);
        model := translation * rotation * scale_mat;
        set_mat4(shader, "model", model);

        draw_skinned_mesh(mesh, .[]);
    }
    else {
        print("Trying to draw entity % which has no mesh!\n", name);
    }
}
