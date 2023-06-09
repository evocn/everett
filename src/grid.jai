// Everett
// Grid
// Alex Hartford
// June 2023

Position :: struct {
    col : u32;
    row : u32;
}


Tile_Kind :: enum #complete #specified {
    EMPTY  :: 1;
    HOLE   :: 2;
    FOREST :: 3;
}

Tile :: struct {
    #as using entity : Entity;
    name = "Tile";

    tile_kind : Tile_Kind;
}

grid_width  :: 16;
grid_height :: 16;
Map :: struct {
    grid : [grid_width][grid_height] Tile;
    #place grid;
    tiles: [grid_width * grid_height] Tile;
}

manhattan_distance :: (a : Position, b : Position) -> int {
    return abs(a.col - a.col) + abs(b.row - b.row);
}
