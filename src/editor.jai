// Everett
// Editor
// Alex Hartford
// June 2023

update_and_draw_editor :: (entities : *[..] *Entity) {
    io := ImGui.GetIO();
    program_state.imgui_capturing_mouse    = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard = io.WantCaptureKeyboard;
    program_state.framerate = io.Framerate;

    if !program_state.imgui_capturing_mouse {
        if program_state.mode == .EDITOR {
            maybe_select_entity(entities.*);
        }
    }

    //
    //

    ImGui_ImplSdl_NewFrame(window);
    ImGui.NewFrame();

    draw_all_windows(entities);

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

draw_all_windows :: (entities : *[..] *Entity) {
    entities_window(entities);
    if editor.selected_entity != -1 {
        entity_window(entities.*[editor.selected_entity], entities);
    }

    settings_window();

    debug_display_window();
    
    undo_redo_window();

    shadow_frustum_window();
}

theta : float;
entity_window :: (using entity: *Entity, entities : *[..] *Entity) {
    ImGui.Begin("Entity");
    {
        ImGui.Text("% | %", serial, name);

        ImGui.SliderFloat3("Position", *position.component, -50.0, 50.0);

        if ImGui.SliderFloat("X", xx *theta, -PI, PI) {
            set_from_axis_and_angle(*orientation, 1.0, 0.0, 0.0, xx theta);
        }

        ImGui.SliderFloat("Scale", *scale, 0.0, 3.0);

        if ImGui.Button("delete") {
            delete_entity(entities, editor.selected_entity);
            editor.selected_entity = -1;
        }
        ImGui.SameLine();
        if ImGui.Button("copy") {
            duplicate_entity(entities, editor.selected_entity);
            editor.selected_entity += 1;
        }

        for mesh_catalogue {
            if ImGui.Selectable(to_c_string(tprint("%", it_index)), entities.*[editor.selected_entity].mesh_name == it_index) {
                entities.*[editor.selected_entity].mesh_name = it_index;
                find_entity_mesh(entities.*[editor.selected_entity]);
            }
        }
    }
    ImGui.End();
}

entities_window :: (entities : *[..] *Entity) {
    ImGui.Begin("Entities");
    {
        ImGui.Text("Current level: %", program_state.current_level_name);
        if(ImGui.Button("Save")) {
            success := save_entities(entities.*, program_state.current_level_name);
        }
        ImGui.SameLine();
        if(ImGui.Button("load")) {
            success := load_entities(entities, program_state.current_level_name);
        }

        if ImGui.BeginListBox("###420", Vector2.{-FLOAT32_MIN, -FLOAT32_MIN}) {
            for entities.* {
                if ImGui.Selectable(to_c_string(tprint("% | %", it_index, it.name)), editor.selected_entity == it_index)
                    editor.selected_entity = it_index;
            }
            ImGui.EndListBox();
        }
    }
    ImGui.End();
}

settings_window :: () {
    ImGui.Begin("Settings");
    {
        ImGui.Checkbox("Line Mode", *settings.line_mode);
        ImGui.Checkbox("Bounding Boxes", *settings.draw_bounding_boxes);
        ImGui.Checkbox("Shadow Debug", *settings.shadow_debug);
    }
    ImGui.End();
}

undo_redo_window :: () {
    ImGui.Begin("Commands");
    {
        // @Cleanup: Just gray these out instead of not showing them.
        undo_available := current_editor_command_index != -1;
        redo_available := current_editor_command_index < editor_commands.count - 1;
        if undo_available {
            if ImGui.Button("Undo") {
                undo_last_command();
            }
        }

        if redo_available {
            ImGui.SameLine(ImGui.GetWindowWidth() - 200);
            if ImGui.Button("Redo") {
                redo_next_command();
            }
        }

        if ImGui.BeginListBox("###1001", Vector2.{-FLOAT32_MIN, -FLOAT32_MIN}) {
            for editor_commands {
                ImGui.Selectable(to_c_string(tprint("% | %", it_index, it.name)), current_editor_command_index == it_index);
            }
            ImGui.EndListBox();
        }
    }
    ImGui.End();
}

shadow_frustum_window :: () {
    ImGui.Begin("Shadow Frustum");
    {
        orthographic_frustum_editor(*shadow_map.frustum);
        ImGui.SliderFloat3("Origin", *shadow_map.light_position.component, -1.0, 1.0);
    }
    ImGui.End();
}

orthographic_frustum_editor :: (frustum : *Orthographic_Frustum) {
    ImGui.SliderFloat("Near", *frustum.near, -50.0, 50.0);
    ImGui.SliderFloat("Far",  *frustum.far, -50.0, 50.0);
    ImGui.SliderFloat("Width",  *frustum.width, -50.0, 50.0);
    ImGui.SliderFloat("Height",  *frustum.height, -50.0, 50.0);
}

//
//

debug_display_window :: () {
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
