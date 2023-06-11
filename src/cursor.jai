// Everett
// Grid
// Alex Hartford
// June 2023

// The new command architecture:
// * Inputs flow through the whole program, everything can see its state.
// * We call update_cursor every frame.
// * We only eat the inputs and change state if it's our turn.
// * UI does the same.
// * Therefore, we don't put everything in one monolithic command hierarchy, but rather two.

// Isn't software engineering grand?

cursor : struct {
    using square : Square = .{grid_width / 2, grid_height / 2};

    selected : *Unit;
    selected_initial_square : Square = .{-1, -1};

    accessible : [..] Square;

    // I like the into the breach states, where you're only ever really holding a unit when they move, or when you're targeting.
    // Everything else is just: "Push a button when you're over a unit, maybe you'll end up in a state."
    // In any case, not so deterministic this time.
    /*
    state : enum {
        NEUTRAL;
        // No movement restrictions.
        MOVING_UNIT;
        // Give a soft limit when you aren't moving in the range.
        TARGETING_ATTACK;
        // Hard limit? Maybe just soft limit.
    }
    */
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

    if input.shift {
        deselect_unit(map);
        input.shift = false;
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
        accessible = accessible_squares_from_position(map, square, selected.movement);
    }
}

deselect_unit :: (map : *Map) {
    using cursor;

    if selected {
        square = selected_initial_square;
        selected_initial_square = .{-1, -1};
        array_reset(*accessible);
    }
    selected = null;
}

attempt_place_selected_unit :: (map : *Map) {
    using cursor;

    if get_occupant(map, square) return;
    if !array_find(accessible, square) return;

    remove_occupant(map, selected_initial_square);
    occupy(map, square, selected);
    selected.square = square;
    selected = null;
    selected_initial_square = Square.{-1, -1};
    array_reset(*accessible);
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

