// Everett
// Editor
// Alex Hartford
// June 2023

update_and_draw_editor :: (units : *[..] *Unit, meshes : Table(string, *Skinned_Mesh)) {
    io := ImGui.GetIO();
    program_state.framerate = io.Framerate;

    ImGui_ImplSdl_NewFrame(window);

    ImGui.NewFrame();
    program_state.imgui_capturing_mouse    = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard = io.WantCaptureKeyboard;

    meshes_display(meshes);
    units_editor(units, meshes);
    if editor.selected_unit != -1 {
        unit_editor((<<units)[editor.selected_unit], units);
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

unit_editor :: (using unit: *Unit, units : *[..] *Unit) {
    ImGui.Begin("Unit");
    {
        ImGui.Text("%", name);
        ImGui.SameLine();
        if ImGui.Button("remove") {
            // @TODO: Make this a command
            array_ordered_remove_by_index(units, editor.selected_unit);
            editor.selected_unit = -1;
        }
        ImGui.SameLine();
        if ImGui.Button("copy") {
            // @TODO: Make this a command
            new_unit := New(Unit);
            memcpy(new_unit, unit, size_of(Unit));
            array_add(units, new_unit);
            editor.selected_unit = units.count-1;
        }
        // INSPECT HERE!
    }
    ImGui.End();
}

units_editor :: (units : *[..] *Unit, meshes : Table(string, *Skinned_Mesh)) {
    ImGui.Begin("Units");
    {
        ImGui.Text("Current level: %", program_state.current_level_name);
        if(ImGui.Button("Save")) {
            save_units(<<units, program_state.current_level_name);
        }
        ImGui.SameLine();
        if(ImGui.Button("load")) {
            load_units(units, meshes, program_state.current_level_name);
        }

        if ImGui.BeginListBox("###420") {
            for <<units {
                if ImGui.Selectable(to_c_string(tprint("% | %", it_index, it.name)), editor.selected_unit == it_index)
                    editor.selected_unit = it_index;
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
        ImGui.Text("Selected Entity: %", editor.selected_unit);
        ImGui.Text("Selected Mesh: %", editor.selected_mesh);

        ImGui.Text("average % ms/frame (% FPS)", 
                   formatFloat(1000.0 / program_state.framerate, trailing_width=2), 
                   formatFloat(program_state.framerate, trailing_width=2)
                  );
    }
    ImGui.End();
}
