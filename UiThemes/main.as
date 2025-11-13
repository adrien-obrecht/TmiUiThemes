uint num_important_variables = 15;
uint num_medium_variables = 17;
array<string> ui_variables = {
    "ui_color_text",
    "ui_color_window_bg",
    "ui_color_child_bg",
    "ui_color_frame_bg",
    "ui_color_frame_bg_hovered",
    "ui_color_frame_bg_active",
    "ui_color_title_bg", 
    "ui_color_title_bg_active",
    "ui_color_title_bg_collapsed",
    "ui_color_sidebar_button",
    "ui_color_tab",
    "ui_color_tab_hovered",
    "ui_color_tab_active",
    "ui_color_tab_unfocused",
    "ui_color_tab_unfocused_active",

    "ui_color_popup_bg",
    "ui_color_scrollbar_bg",
    "ui_color_scrollbar_grab",
    "ui_color_scrollbar_grab_hovered",
    "ui_color_scrollbar_grab_active",
    "ui_color_check_mark",
    "ui_color_slider_grab",
    "ui_color_slider_grab_active",
    "ui_color_button",
    "ui_color_button_hovered",
    "ui_color_button_active",
    "ui_color_separator",
    "ui_color_separator_hovered",
    "ui_color_separator_active",
    "ui_color_resize_grip",
    "ui_color_resize_grip_hovered",
    "ui_color_resize_grip_active",

    "ui_color_border",
    "ui_color_border_shadow",
    "ui_color_menu_bar_bg",
    "ui_color_header",
    "ui_color_header_hovered",
    "ui_color_header_active",
    "ui_color_text_disabled",
    "ui_color_plot_lines",
    "ui_color_plot_lines_hovered",
    "ui_color_plot_histogram",
    "ui_color_plot_histogram_hovered",
    // "ui_color_table_header_bg",
    // "ui_color_table_border_strong",
    // "ui_color_table_border_light",
    // "ui_color_table_row_bg",
    // "ui_color_table_row_bg_alt",
    "ui_color_text_selected_bg",
    "ui_color_drag_drop_target",
    "ui_color_nav_highlight",
    "ui_color_nav_windowing_highlight",
    // "ui_color_nav_windowing_dim_bg",
    "ui_color_modal_window_dim_bg",
};

int StringToInt(const string &in s) {
    int result = 0;
    bool negative = false;
    uint i = 0;

    // Handle optional sign
    if (s.Length > 0 && s[0] == '-') {
        negative = true;
        i = 1;
    }

    // Parse digits manually
    for (; i < s.Length; i++) {
        uint8 c = s[i];
        if (c < '0' || c > '9') break; // stop at first non-digit
        result = result * 10 + (c - '0');
    }

    if (negative)
        result = -result;

    return result;
}
                  
void SelectVariable(string var_name) {
    string active_preset = GetVariableString("ui_preset_active");
    string value;
    GetVariable(Prefix(active_preset) + var_name, value);
    array<string>@ parts = value.Split(",");
    
    array<float> values(4);
    for (uint i = 0; i < 4; i++) {
        values[i] = float(StringToInt(parts[i]));
    }

    UI::PushItemWidth(64.0f);

    UI::PushStyleColor(UI::Col::Text, vec4(1.0f, 0.0f, 0.0f, 1.0f));
    values[0] =  UI::SliderFloat("##r" + var_name, values[0], 0.0f, 255.0f, "%.0f");

    UI::SameLine();
    UI::PushStyleColor(UI::Col::Text, vec4(0.0f, 1.0f, 0.0f, 1.0f));
    values[1] =  UI::SliderFloat("##g" + var_name, values[1], 0.0f, 255.0f, "%.0f");

    UI::SameLine();
    UI::PushStyleColor(UI::Col::Text, vec4(0.0f, 0.0f, 1.0f, 1.0f));
    values[2] =  UI::SliderFloat("##b" + var_name, values[2], 0.0f, 255.0f, "%.0f");

    UI::SameLine();
    UI::PushStyleColor(UI::Col::Text, vec4(1.0f, 1.0f, 1.0f, 1.0f));
    values[3] =  UI::SliderFloat("##a" + var_name, values[3], 0.0f, 255.0f, "%.0f");

    UI::SameLine();
    vec4 new_colors = vec4(values[0] / 255, values[1] / 255, values[2] / 255, values[3] / 255);
    UI::PushStyleColor(UI::Col::Button, new_colors);
    UI::BeginDisabled();
    UI::Button("    ");
    UI::EndDisabled();

    UI::PopStyleColor(5);
    UI::PopItemWidth();


    string output = "" + values[0] + "," + values[1] + "," + values[2] + "," + values[3];
    SetVariable(Prefix(active_preset) + var_name, output);

    UI::SameLine();
    UI::Text(var_name.Substr(9));  // Remove ui_color_
}

bool preview = false;

string Prefix(string i) {
    return "ui_preset" + i + "_";
}

void LoadThemePreset() {
    string active_preset = GetVariableString("ui_preset_active");
    for (uint i = 0; i < ui_variables.Length; i++) {
        string var = GetVariableString(Prefix(active_preset) + ui_variables[i]);
        SetVariable(ui_variables[i], var);
    }
}

void RenderThemesSettings()
{
    string active_preset = GetVariableString("ui_preset_active");
    string theme = GetVariableString(Prefix(active_preset) + "ui_theme");

    if (UI::BeginTabBar("Presets")) {
        for (int i = 1; i < 4; i++) {
            string preset_name = GetVariableString(Prefix(""+i) + "name");
            if (UI::BeginTabItem("    " + preset_name + "    ###preset_" + i)) {
                SetVariable("ui_preset_active", ""+i);
                string new_name = UI::InputText("Name", preset_name);
                SetVariable(Prefix(""+i) + "name", new_name);
                UI::EndTabItem();
            }
        }
        UI::EndTabBar();     
    }

    bool hovering = false;
    if (UI::BeginCombo("Base theme", theme)) {
        for (uint i = 0; i < themes.Length - 1; i++) {
            UI::Button("Test");
            if (UI::IsItemHovered()) {
                SetupTheme(themes[i], "");
                hovering = true;
            }

            UI::SameLine();
            
            bool selected = (themes[i] == theme);

            if (UI::Selectable(themes[i], selected)) {
                SetVariable(Prefix(active_preset) +  "ui_theme", themes[i]);
                SetupTheme(themes[i], Prefix(active_preset));
            }

            if (UI::IsItemHovered()) {
                UI::BeginTooltip();
                UI::Text(getDescription(themes[i]) + " by " + getAuthor(themes[i]));
                array<string>@ parts = getTags(themes[i]).Split(",");
                for (uint id = 0; id < parts.Length; id++) {
                    UI::Button(parts[id]);
                    UI::SameLine();
                }
                UI::EndTooltip();
            }

        }

        UI::EndCombo();
    }
    

    bool collapsed = UI::CollapsingHeader("Basic configuration");
    for (uint i = 0; i < ui_variables.Length - 1; i++) {
        if (i == num_important_variables) {
            collapsed = UI::CollapsingHeader("Advanced configuration");
        }
        if (i == num_important_variables + num_medium_variables) {
            collapsed = UI::CollapsingHeader("Very advanced configuration");
        }
        if (collapsed)
            SelectVariable(ui_variables[i]);
    }

    if (!hovering)
        LoadThemePreset();
}


void Main()
{
    RegisterSettingsPage("Themes", RenderThemesSettings);
    RegisterVariable("ui_preset_active", "1");
    
    for (int i = 1; i < 4; i++) {
        RegisterVariable(Prefix(""+i) + "name", "Profile " + i);
        RegisterVariable(Prefix(""+i) + "ui_theme", "Classic");
        RegisterVariable(Prefix(""+i) + "init", false);
        for (uint j = 0; j < ui_variables.Length; j++) {
            RegisterVariable(Prefix(""+i) + ui_variables[j], "0,0,0,0");
        }
        if (!GetVariableBool(Prefix(""+i) + "init")) {
            SetupTheme("Classic", Prefix(""+i));
            SetVariable(Prefix(""+i) + "init", true);
        }
    }
}

PluginInfo@ GetPluginInfo()
{
    auto info = PluginInfo();
    info.Name = "Ui Themes";
    info.Author = "Adrien";
    info.Version = "v1.1.0";
    info.Description = "ImGui themes, with profiles and customization !";
    return info;
}