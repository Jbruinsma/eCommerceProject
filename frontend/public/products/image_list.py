import os

# --- 1. CONFIGURATION ---
# Absolute path to your product images folder
IMAGE_DIR = 'C:/Users/justi/Desktop/currentProjects/eCommerceProject/frontend/public/products/'

# Absolute path to the SQL file you want to read
SQL_INPUT_FILE = 'C:/Users/justi/Desktop/currentProjects/eCommerceProject/sql/dummy_data.sql'

# Absolute path for the new, corrected SQL file we will create
SQL_OUTPUT_FILE = '/sql/dummy_data.sql'


# --------------------------

def create_extension_map(image_dir):
    """Scans the image directory and maps base filenames to their extensions."""
    extension_map = {}
    print(f"Scanning {image_dir} for images...")
    try:
        for filename in os.listdir(image_dir):
            base_name, extension = os.path.splitext(filename)
            if extension:
                # This check prevents the script from reading itself
                if base_name == "image_list" and extension == ".py":
                    continue
                extension_map[base_name] = extension
                print(f"  > Found: {base_name} -> {extension}")

    except FileNotFoundError:
        print(f"\n--- !! ERROR !! ---")
        print(f"Image directory not found: '{image_dir}'")
        print("Please make sure the IMAGE_DIR variable in this script is correct.")
        print("-------------------\n")
        return None
    except Exception as e:
        print(f"An error occurred while scanning directory: {e}")
        return None

    print(f"\nFound {len(extension_map)} image extensions.")
    return extension_map


def process_sql_file(ext_map, input_file, output_file):
    """Reads the SQL file, replaces paths, and writes to a new file."""
    if ext_map is None:
        print("Cannot process SQL file: extension map is empty or failed to build.")
        return

    lines_changed = 0
    total_replacements = 0
    output_lines = []

    print(f"\nProcessing {input_file}...")
    try:
        with open(input_file, 'r', encoding='utf-8') as f_in:
            for line in f_in:
                original_line = line

                for base_name, extension in ext_map.items():
                    find_string = f"'/products/{base_name}'"
                    replace_string = f"'/products/{base_name}{extension}'"

                    if find_string in line:
                        line = line.replace(find_string, replace_string)
                        total_replacements += 1

                if original_line != line:
                    lines_changed += 1

                output_lines.append(line)

        with open(output_file, 'w', encoding='utf-8') as f_out:
            f_out.writelines(output_lines)

        print(f"\n✅ Success!")
        print(f"Made {total_replacements} replacements across {lines_changed} lines.")
        print(f"New file created: {output_file}")

    except FileNotFoundError:
        print(f"\n--- !! ERROR !! ---")
        print(f"SQL file not found: {input_file}")
        print("Please make sure the SQL_INPUT_FILE variable in this script is correct.")
        print("-------------------\n")
    except Exception as e:
        print(f"An error occurred while processing the SQL file: {e}")


# --- Main execution ---
if __name__ == "__main__":
    file_map = create_extension_map(IMAGE_DIR)
    process_sql_file(file_map, SQL_INPUT_FILE, SQL_OUTPUT_FILE)