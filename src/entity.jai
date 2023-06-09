// Everett
// Entity
// Alex Hartford
// June 2023

// @Example
Bird :: struct {
    #as using entity : Entity;
}

Entity_Kind :: enum #complete #specified {
    BIRD :: 1;
    TILE :: 2;
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
