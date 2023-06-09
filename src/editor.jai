// Everett
// Editor
// Alex Hartford
// June 2023

update_and_draw_editor :: (entities : *[..] *Entity, meshes : Table(string, *Skinned_Mesh)) {
    io := ImGui.GetIO();
    program_state.framerate = io.Framerate;

    ImGui_ImplSdl_NewFrame(window);

    ImGui.NewFrame();
    program_state.imgui_capturing_mouse    = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard = io.WantCaptureKeyboard;

    meshes_display(meshes);
    entities_editor(entities, meshes);
    if editor.selected_entity != -1 {
        entity_editor((<<entities)[editor.selected_entity], entities);
    }

    settings_editor();

    debug_display();

    using ImGui.MouseCursor;
    if ImGui.GetMouseCursor() == {
        case Arrow;         SDL_SetCursor(cursor_arrow);
        case TextInput;     SDL_SetCursor(cursor_text_input);
        case Hand;          SDL_SetCursor(cursor_move);
        case ResizeNS;      SDL_SetCursor(cursor_resize_ns);
        case ResizeEW;      SDL_SetCursor(cursor_resize_ew);
        case ResizeNESW;    SDL_SetCursor(cursor_resize_nesw);
        case ResizeNWSE;    SDL_SetCursor(cursor_resize_nwse);
    }

    ImGui.Render();
}

entity_editor :: (using entity: *Entity, entities : *[..] *Entity) {
    ImGui.Begin("Entity");
    {
        ImGui.Text("%", name);
        ImGui.SameLine();
        if ImGui.Button("remove") {
            // @TODO: Make this a command
            array_ordered_remove_by_index(entities, editor.selected_entity);
            editor.selected_entity = -1;
        }
        ImGui.SameLine();
        if ImGui.Button("copy") {
            // @TODO: Make this a command
            new_entity := New(Entity);
            memcpy(new_entity, entity, size_of(Entity));
            array_add(entities, new_entity);
            editor.selected_entity = entities.count-1;
        }
            
        ImGui.SliderFloat3("P", xx *position, -1.0, 1.0);
        ImGui.SliderFloat ("S", xx *scale,     0.0, 3.0);

        // @TODO: Either integrate this better, or don't even bother with my own inspector code...
        // Cuz this is great!
        if kind == {
            case .BIRD;

            case .TILE; {
                tile := cast(*Tile)entity;
                inspect("Tile", tile);
            }
        }
    }
    ImGui.End();
}

entities_editor :: (entities : *[..] *Entity, meshes : Table(string, *Skinned_Mesh)) {
    ImGui.Begin("Entities");
    {
        ImGui.Text("Current level: %", program_state.current_level_name);
        if(ImGui.Button("Save")) {
            save_level(<<entities, program_state.current_level_name);
        }
        ImGui.SameLine();
        if(ImGui.Button("load")) {
            load_level(entities, meshes, program_state.current_level_name);
        }

        if ImGui.BeginListBox("###420") {
            for <<entities {
                if ImGui.Selectable(to_c_string(tprint("% | %", it_index, it.name)), editor.selected_entity == it_index)
                    editor.selected_entity = it_index;
            }
            ImGui.EndListBox();
        }
    }
    ImGui.End();
}

meshes_display :: (meshes : Table(string, *Skinned_Mesh)) {
    ImGui.Begin("Meshes");
    {
        if ImGui.BeginListBox("###69") {
            for meshes {
                if ImGui.Selectable(to_c_string(tprint("%", it_index)), editor.selected_mesh == it_index)
                    editor.selected_mesh = it_index;
            }
            ImGui.EndListBox();
        }
    }
    ImGui.End();
}

settings_editor :: () {
    ImGui.Begin("Settings");
    {
        ImGui.Checkbox("Autosave", *settings.autosave);
        if ImGui.Checkbox("Line Mode", *settings.line_mode) {
            if settings.line_mode
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            else
                glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }
    }
    ImGui.End();
}

//
//

debug_display :: () {
    ImGui.Begin("Debug Display");
    {
        ImGui.Text("Editor");
        ImGui.Text("Selected Entity: %", editor.selected_entity);
        ImGui.Text("Selected Mesh: %", editor.selected_mesh);

        ImGui.Text("average % ms/frame (% FPS)", 
                   formatFloat(1000.0 / program_state.framerate, trailing_width=2), 
                   formatFloat(program_state.framerate, trailing_width=2)
                  );
    }
    ImGui.End();
}
