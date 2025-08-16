import os
import re

# Directory containing GML files
GML_DIR = "scripts"  # Path to your GML files in scripts folder
WIKI_DIR = "wiki"    # Output directory for Markdown files

# Ensure wiki directory exists
if not os.path.exists(WIKI_DIR):
    os.makedirs(WIKI_DIR)

def parse_gml_file(file_path):
    """Parse a GML file and extract JSDoc comments for functions and class parameters."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract function definitions with JSDoc and class parameters
    functions = []
    parameters = []
    current_desc = ""
    current_args = []
    current_return = ""
    current_func = None
    class_desc = ""
    ignore_next = False
    before_constructor = True
    
    lines = content.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith('function') and 'constructor' in line:
            before_constructor = False  # Stop collecting class description and parameters
            i += 1
            continue
        if line.startswith('static') and 'function' in line:
            # Process method
            func_name = re.search(r'static\s+(\w+)\s*=', line)
            if func_name and not ignore_next and not func_name.group(1).startswith('_'):
                current_func = {
                    'name': func_name.group(1),
                    'desc': current_desc,
                    'args': current_args,
                    'return': current_return
                }
                functions.append(current_func)
                print(f"Found method: {func_name.group(1)}")
            current_desc = ""
            current_args = []
            current_return = ""
            ignore_next = False
            i += 1
            continue
        if line.startswith('///@desc') and before_constructor:
            # Handle multi-line @desc for class and parameters
            desc_lines = [line.replace('///@desc', '').strip()]
            print(f"Raw desc line: {desc_lines[0]}")  # Debug raw line
            j = i + 1
            while j < len(lines) and lines[j].strip().startswith('///') and not lines[j].strip().startswith('///@'):
                desc_line = lines[j].replace('///', '').strip()
                desc_lines.append(desc_line)
                print(f"Raw desc line: {desc_line}")  # Debug additional lines
                j += 1
            full_desc = '\n'.join([line for line in desc_lines if line]).strip()
            print(f"Found description block: {full_desc}")
            if "Available parameters:" in full_desc:
                parts = full_desc.split("Available parameters:")
                class_desc = parts[0].strip()
                if len(parts) > 1:
                    param_text = parts[1].strip()
                    parameters = [p.strip() for p in param_text.split('\n') if p.strip()]
                print(f"Found class description: {class_desc}")
                for param in parameters:
                    print(f"Found parameter: {param}")
            else:
                class_desc = full_desc
                print(f"Found class description: {class_desc}")
            i = j
            continue
        elif line.startswith('///@desc'):
            # Handle method description
            desc_lines = [line.replace('///@desc', '').strip()]
            j = i + 1
            while j < len(lines) and lines[j].strip().startswith('///') and not lines[j].strip().startswith('///@'):
                desc_lines.append(lines[j].replace('///', '').strip())
                j += 1
            current_desc = '\n'.join([line for line in desc_lines if line]).strip()
            print(f"Found method description: {current_desc}")
            i = j
            continue
        elif line.startswith('///@arg') and not before_constructor:
            arg = line.replace('///@arg', '').strip()
            current_args.append(arg)
            print(f"Found argument: {arg}")
        elif line.startswith('///@return') and not before_constructor:
            current_return = line.replace('///@return', '').strip()
            print(f"Found return: {current_return}")
        elif line.startswith('///@ignore'):
            ignore_next = True
            print("Found @ignore tag")
        i += 1
    
    print(f"Parsed file: {file_path}")
    print(f"Parameters found: {parameters}")
    print(f"Methods found: {[f['name'] for f in functions]}")
    return functions, class_desc, parameters

def generate_markdown(functions, output_file, class_name, class_desc, parameters):
    """Generate Markdown content for Wiki."""
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"# {class_name}\n\n")
        if class_desc:
            f.write(f"{class_desc}  \n")
        else:
            f.write("A GameMaker Studio class.  \n")
        if parameters:
            f.write("**Available parameters:**  \n")
            for param in parameters:
                f.write(f"{param}  \n")
            f.write("\n")
        if functions:
            f.write("## Methods\n")
            for func in functions:
                f.write(f"### `{func['name']}`\n")
                f.write(f"{func['desc']}\n\n")
                if func['args']:
                    f.write("**Parameters:**  \n")
                    for arg in func['args']:
                        f.write(f"- `{arg}`  \n")
                    f.write("\n")
                if func['return']:
                    f.write("**Returns:**  \n")
                    f.write(f"- `{func['return']}`  \n")
                f.write("\n")

# Process all GML files in scripts folder and its subfolders
ignored_files = {'LuiAdditional', 'LuiEvents', 'LuiMessage', 'LuiSettings', 'LuiStyles', 'Luitween'}
all_classes = {}
for root, dirs, files in os.walk(GML_DIR):
    print(f"Scanning folder: {root}")
    for filename in files:
        if filename.endswith('.gml') and filename.startswith('Lui'):
            class_name = filename.replace('.gml', '')
            if class_name in ignored_files:
                print(f"Skipped GML file (ignored): {filename}")
                continue
            print(f"Found GML file: {filename}")
            file_path = os.path.join(root, filename)
            functions, class_desc, parameters = parse_gml_file(file_path)
            all_classes[class_name] = {
                'functions': functions,
                'desc': class_desc,
                'parameters': parameters
            }
        elif filename.endswith('.gml'):
            print(f"Skipped GML file (no Lui prefix): {filename}")

# Generate LuiBase.md separately
if 'LuiBase' in all_classes:
    output_file = os.path.join(WIKI_DIR, "LuiBase.md")
    print(f"Generating Markdown: {output_file}")
    generate_markdown(
        all_classes['LuiBase']['functions'],
        output_file,
        'LuiBase',
        all_classes['LuiBase']['desc'],
        all_classes['LuiBase']['parameters']
    )
    del all_classes['LuiBase']  # Remove LuiBase from all_classes to exclude it from Components.md

# Generate Components.md for all other Lui* classes
output_file = os.path.join(WIKI_DIR, "Components.md")
print(f"Generating Markdown: {output_file}")
with open(output_file, 'w', encoding='utf-8') as f:
    for class_name, data in all_classes.items():
        f.write(f"# {class_name}\n\n")
        if data['desc']:
            f.write(f"{data['desc']}  \n")
        else:
            f.write("A GameMaker Studio class.  \n")
        if data['parameters']:
            f.write("**Available parameters:**  \n")
            for param in data['parameters']:
                f.write(f"{param}  \n")
            f.write("\n")
        if data['functions']:
            f.write("## Methods\n")
            for func in data['functions']:
                f.write(f"### `{func['name']}`\n")
                f.write(f"{func['desc']}\n\n")
                if func['args']:
                    f.write("**Parameters:**  \n")
                    for arg in func['args']:
                        f.write(f"- `{arg}`  \n")
                    f.write("\n")
                if func['return']:
                    f.write("**Returns:**  \n")
                    f.write(f"- `{func['return']}`  \n")
                f.write("\n")