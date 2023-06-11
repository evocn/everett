// Everett
// Unit
// Alex Hartford
// June 2023

// Choices:
// Entities that are units can just have the Unit struct attached.
// Entities that are units can be units.

// To be honest, I don't have enough information to judge which will be best
// long-term, but for now I'll go with #2.

Unit :: struct {
    name : string;

    direction : Direction;
    using square : Square;

    mesh_name : string;
    mesh : *Skinned_Mesh;
}
