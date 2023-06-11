// Everett
// Grid
// Alex Hartford
// June 2023

Square :: struct {
    col : int;
    row : int;
}

Direction :: enum {
    NORTH;
    SOUTH;
    EAST;
    WEST;
}

//
//

Tile_Kind :: enum #complete #specified {
    PLAIN  :: 0;
    HOLE   :: 1;
    FOREST :: 2;
}

Tile :: struct {
    tile_kind : Tile_Kind;
}

grid_width  :: 11;
grid_height :: 11;
Map :: struct {
    grid : [grid_width][grid_height] Tile;
    #place grid;
    tiles: [grid_width * grid_height] Tile;

    occupancy : [grid_width][grid_height] *Unit;

    cube_mesh : *Skinned_Mesh;
}

get_occupant :: (using map: Map, using square: Square) -> *Unit {
    return occupancy[col][row];
}

remove_occupant :: (using map: *Map, using square: Square) {
    occupancy[col][row] = null;
}

occupy :: (using map: *Map, using square: Square, unit: *Unit) {
    occupancy[col][row] = unit;
}

//
//

on_grid :: (using square : Square) -> bool {
    return col >= 0 && col < grid_width && row >= 0 && row < grid_height;
}

manhattan_distance :: (a : Square, b : Square) -> int {
    return abs(a.col - a.col) + abs(b.row - b.row);
}
