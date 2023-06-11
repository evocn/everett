// Everett
// Unit
// Alex Hartford
// June 2023

Team :: enum {
    NONE;
    BLUE;
    RED;
    GREEN;
}

Unit :: struct {
    name : string;

    mesh_name : string;

    direction : Direction;
    using square : Square;

    team : Team;
    movement : int;
    range : int;
}

//
//

// @TODO: Min range too!
get_interactible_squares_from_position :: (origin : Square, max: int) -> [..] Square
{
    interactible: [..] Square;

    costs : [grid_width][grid_height] int;
    // This currently just fills the grid with giant integers, so our costs start high for the algorithm.
    memset(*costs, 1, grid_width * grid_height * size_of(int));

    rows := int.[-1,  0,  1,  0];
    cols := int.[ 0,  1,  0, -1];

    unexplored : [..] Square;
    array_add(*unexplored, origin);
    costs[origin.col][origin.row] = 0;

    while unexplored {
        using current_square := pop(*unexplored);
        array_add(*interactible, current_square);

        for i : 0..3 {
            new_square := Square.{col + cols[i], row + rows[i]};
            if !on_grid(new_square) then continue;

            new_cost := costs[col][row] + 1;
            new_cost_is_less_than_old_cost := new_cost < costs[new_square.col][new_square.row];

            if new_cost_is_less_than_old_cost 
            {
                costs[new_square.col][new_square.row] = new_cost;

                if new_cost <= max
                    array_add(*unexplored, new_square);
            }
        }
    }

    return interactible;
}

get_accessible_squares_from_position :: (using map : Map, unit : Unit) -> [..] Square
{
    accessible: [..] Square;

    costs : [grid_width][grid_height] int;
    memset(*costs, 1, grid_width * grid_height * size_of(int));

    rows := int.[-1,  0,  1,  0];
    cols := int.[ 0,  1,  0, -1];

    unexplored : [..] Square;
    array_add(*unexplored, unit.square);
    costs[unit.col][unit.row] = 0;

    while unexplored {
        using current_square := pop(*unexplored);
        array_add(*accessible, current_square);

        for i : 0..3 {
            new_square := Square.{col + cols[i], row + rows[i]};
            if !on_grid(new_square) then continue;

            new_cost := costs[col][row] + 1;

            new_square_occupant := get_occupant(map, new_square);
            new_square_is_not_occupied_by_enemy_unit := new_square_occupant == null || new_square_occupant.team == unit.team;
            new_square_is_passible := !is_impassible(get_tile(map, new_square));
            new_cost_is_less_than_old_cost := new_cost < costs[new_square.col][new_square.row];

            if new_cost_is_less_than_old_cost && new_square_is_not_occupied_by_enemy_unit && new_square_is_passible
            {
                costs[new_square.col][new_square.row] = new_cost;

                if new_cost <= unit.movement
                    array_add(*unexplored, new_square);
            }
        }
    }

    filter_out_occupied(*accessible, map);
    array_add(*accessible, unit.square);

    return accessible;

}


/*
// Finds the nearest unit to the cursor, based on the given predicate expression.
Unit *FindNearest(const Tilemap &map, const position &origin, 
                  bool predicate(const Unit &), bool is_ally)
{
    int minDistance = 100;
    int distance = 0;
    Unit *result = nullptr;
    for(int col = 0; col < map.width; ++col)
    {
        for(int row = 0; row < map.height; ++row)
        {
            if(map.tiles[col][row].occupant && predicate(*map.tiles[col][row].occupant))
            {
                distance = GetPath(map, origin, position(col, row), is_ally).size();
                if(distance < minDistance)
                {
                    result = map.tiles[col][row].occupant;
                    minDistance = distance;
                }
            }
        }
    }
    return result;
}
*/
