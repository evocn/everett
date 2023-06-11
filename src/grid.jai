// Everett
// Grid
// Alex Hartford
// June 2023

Square :: struct {
    col : int;
    row : int;
}

operator == :: (a: Square, b: Square) -> bool {
    return a.col == b.col && a.row == b.row;
}
// @NOTE: This is a method of telling a module about something from my namespace.
// In this case, I'm telling Basic about my ==, so that I can use array_find with squares.
#poke_name Basic operator==;

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

is_impassible :: (using tile: Tile) -> bool {
    if tile_kind == .HOLE
    {
        return true;
    }
    return false;
}

filter_out_impassible :: (squares : *[..] Square, using map: Map) {
    for <<squares {
        tile := get_tile(map, it);
        if is_impassible(tile) remove it;
    }

}

filter_out_occupied :: (squares : *[..] Square, using map: Map) {
    for << squares {
        if get_occupant(map, it) remove it;
    }
}


//
//

grid_width  :: 11;
grid_height :: 11;
Map :: struct {
    grid : [grid_width][grid_height] Tile;
    #place grid;
    tiles: [grid_width * grid_height] Tile;

    occupancy : [grid_width][grid_height] *Unit;
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

get_tile :: (using map: Map, using square: Square) -> *Tile {
    return *grid[col][row];
}

//
//

on_grid :: (using square : Square) -> bool {
    return col >= 0 && col < grid_width && row >= 0 && row < grid_height;
}

manhattan_distance :: (a : Square, b : Square) -> int {
    return abs(a.col - a.col) + abs(b.row - b.row);
}
