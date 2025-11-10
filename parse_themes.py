import toml
import re

def printable_name(name):
    return ''.join(char for char in name if char.isalpha())

with open("themes.as", 'w') as fas:
    with open("themes.toml", "r") as f:
        parsed_toml = toml.loads(f.read())
        fas.write("""
string current = "";
string prevCurrent = "";

void Render()
{
    current = GetVariableString("ui_theme");

    if (prevCurrent != current)
    {""")
        for theme in parsed_toml["themes"]:
            fas.write(f"""
        if (current == "{printable_name(theme["name"])}")
        {{
            Setup{printable_name(theme["name"])}Style();
        }}""")
        fas.write("""
    }
    
    prevCurrent = current;
}
                  
void themeOption(string option)
{
    if (UI::Selectable(option, false)) SetVariable("ui_theme", option);
}

void RenderThemesSettings()
{
    if (UI::BeginCombo("Current theme", current)) 
    {""")
        for theme in parsed_toml["themes"]:
            fas.write(f"""
        themeOption("{printable_name(theme["name"])}");""")
        fas.write("""
        UI::EndCombo();
    }
}

void Main()
{
    RegisterSettingsPage("Themes", RenderThemesSettings);
    RegisterVariable("ui_theme", "Default");
}

PluginInfo@ GetPluginInfo()
{
    auto info = PluginInfo();
    info.Name = "Ui Themes";
    info.Author = "Adrien";
    info.Version = "v1.0.0";
    info.Description = "ImGui themes from ImThemes";
    return info;
}
""")
        for theme in parsed_toml["themes"]:
            fas.write(f"""void Setup{printable_name(theme["name"])}Style() {{\n""")
            colors = theme["style"]["colors"]
            for color in colors:
                tmi_name = "ui_color_" + re.sub(r'(?<!^)(?=[A-Z])', '_', color).lower()
                rgba = [int(float(x)*255) if '.' in x else int(x) for x in re.findall(r"[\d.]+", colors[color])]
                fas.write(f"""\tSetVariable("{tmi_name}", "{rgba[0]},{rgba[1]},{rgba[2]},{rgba[3]}");\n""")
            fas.write("}\n")