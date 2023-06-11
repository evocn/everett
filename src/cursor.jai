// Everett
// Grid
// Alex Hartford
// June 2023

cursor : struct {
    using square : Square;

    mesh : *Skinned_Mesh;

    selected : *Unit;
    selected_initial_square : Square = .{-1, -1};
}

update_cursor :: (map : *Map) {
    using cursor;

    maybe_move_cursor();

    if input.space {
        if selected {
            attempt_place_selected_unit(map);
        }
        else {
            attempt_select_unit(map);
        }
        input.space = false;
    }
}

maybe_move_cursor :: () {
    if input.w {
        move_cursor(.NORTH);
        input.w = false;
    }
    if input.a {
        move_cursor(.EAST);
        input.a = false;
    }
    if input.s {
        move_cursor(.SOUTH);
        input.s = false;
    }
    if input.d {
        move_cursor(.WEST);
        input.d = false;
    }
}

attempt_select_unit :: (map : *Map) {
    using cursor;

    selected = get_occupant(map, square);
    if selected {
        selected_initial_square = square;
    }
}

attempt_place_selected_unit :: (map : *Map) {
    using cursor;

    if get_occupant(map, square) return;

    remove_occupant(map, selected_initial_square);
    occupy(map, square, selected);
    selected.square = square;
    selected = null;
    selected_initial_square = Square.{-1, -1};
}

move_cursor :: (direction : Direction) {
    using cursor;

    new_square : Square;
    if direction == {
        case .NORTH; new_square = Square.{col,   row-1};
        case .SOUTH; new_square = Square.{col,   row+1};
        case .EAST;  new_square = Square.{col-1, row};
        case .WEST;  new_square = Square.{col+1, row};
    }

    if on_grid(new_square)
        square = new_square;
}
