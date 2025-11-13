import toml
import re

def printable_name(name):
    return ''.join(char for char in name if char.isalpha())

with open("UiThemes/import.as", 'w') as fas:
    with open("themes.toml", "r") as f:
        parsed_toml = toml.loads(f.read())
        fas.write("void SetupTheme(string theme, string preset) {\n")
        for theme in parsed_toml["themes"]:
            fas.write(f"""\tif (theme == "{printable_name(theme["name"])}") Setup{printable_name(theme["name"])}Style(preset);\n""")
        fas.write("}\n")

        for theme in parsed_toml["themes"]:
            fas.write(f"""void Setup{printable_name(theme["name"])}Style(string preset) {{\n""")
            colors = theme["style"]["colors"]
            colors["SidebarButton"] = colors["FrameBgActive"]
            for color in colors:
                tmi_name = "ui_color_" + re.sub(r'(?<!^)(?=[A-Z])', '_', color).lower()
                rgba = [int(float(x)*255) if '.' in x else int(x) for x in re.findall(r"[\d.]+", colors[color])]
                fas.write(f"""\tSetVariable(preset + "{tmi_name}", "{rgba[0]},{rgba[1]},{rgba[2]},{rgba[3]}");\n""")
            fas.write("}\n")

        fas.write("array<string> themes = {\n")
        for theme in parsed_toml["themes"]:
            fas.write(f"""\t"{printable_name(theme["name"])}",\n""")
        fas.write("};\n")

        fas.write("string getAuthor(string theme) {\n\tdictionary theme_authors = dictionary();\n")
        for theme in parsed_toml["themes"]:
            fas.write(f"""\ttheme_authors["{printable_name(theme["name"])}"] = "{theme["author"]}";\n""")
        fas.write("\treturn string(theme_authors[theme]);\n}\n")

        
        fas.write("string getDescription(string theme) {\n\tdictionary theme_descriptions = dictionary();\n")
        for theme in parsed_toml["themes"]:
            fas.write(f"""\ttheme_descriptions["{printable_name(theme["name"])}"] = "{theme["description"]}";\n""")
        fas.write("\treturn string(theme_descriptions[theme]);\n}\n")

        fas.write("string getTags(string theme) {\n\tdictionary theme_tags = dictionary();\n")
        for theme in parsed_toml["themes"]:
            tags = ",".join(theme["tags"])
            fas.write(f"""\ttheme_tags["{printable_name(theme["name"])}"] = "{tags}";\n""")
        fas.write("\treturn string(theme_tags[theme]);\n}\n")