import os
import re

# --- 1. CONFIGURATION ---
# Update these paths as needed
IMAGE_DIR = 'C:/Users/justi/Desktop/currentProjects/eCommerceProject/frontend/public/products/'
SQL_INPUT_FILE = 'C:/Users/justi/Desktop/currentProjects/eCommerceProject/sql/dummy_data.sql'
SQL_OUTPUT_FILE = '/sql/dummy_data.sql'


# --------------------------

def create_extension_map(image_dir):
    """Scans the image directory and maps base filenames to their extensions."""
    extension_map = {}
    print(f"Scanning {image_dir} for images...")
    try:
        for filename in os.listdir(image_dir):
            base_name, extension = os.path.splitext(filename)
            # Ignore hidden files or the script itself
            if extension and not base_name.startswith('.'):
                if base_name == "image_list" and extension == ".py":
                    continue
                extension_map[base_name] = extension

    except FileNotFoundError:
        print(f"Error: Image directory not found: '{image_dir}'")
        return None

    print(f"Found {len(extension_map)} valid images in folder.")
    return extension_map


def process_sql_file(ext_map, input_file, output_file):
    if ext_map is None:
        return

    lines_changed = 0
    total_replacements = 0
    missing_files = set()  # Store missing filenames here
    output_lines = []

    # Regex to find '/products/something.ext'
    path_pattern = re.compile(r"'/products/([^']+)'")

    print(f"\nProcessing {input_file}...")

    try:
        with open(input_file, 'r', encoding='utf-8') as f_in:
            for line in f_in:
                original_line = line

                def replace_match(match):
                    nonlocal total_replacements
                    full_match = match.group(0)  # '/products/shoe.jpg'
                    current_filename = match.group(1)  # 'shoe.jpg'

                    # Strip extension to get base name (e.g., 'shoe')
                    base_name_in_sql, _ = os.path.splitext(current_filename)

                    # Check if the base name exists in our folder map
                    if base_name_in_sql in ext_map:
                        correct_ext = ext_map[base_name_in_sql]
                        new_filename = f"{base_name_in_sql}{correct_ext}"

                        if current_filename != new_filename:
                            total_replacements += 1
                            return f"'/products/{new_filename}'"
                        return full_match
                    else:
                        # File found in SQL but NOT in folder
                        missing_files.add(current_filename)
                        return full_match

                # Apply regex
                new_line = path_pattern.sub(replace_match, line)

                if new_line != original_line:
                    lines_changed += 1

                output_lines.append(new_line)

        # Write the new file
        with open(output_file, 'w', encoding='utf-8') as f_out:
            f_out.writelines(output_lines)

        # --- FINAL REPORT ---
        print(f"\n✅ SQL Update Complete!")
        print(f"   - Lines updated: {lines_changed}")
        print(f"   - Paths corrected: {total_replacements}")
        print(f"   - New file: {output_file}")

        if missing_files:
            print(f"\n⚠️  WARNING: {len(missing_files)} images referenced in SQL were NOT found in your folder:")
            print("-" * 60)
            for missing in sorted(missing_files):
                print(f"   ❌ {missing}")
            print("-" * 60)
            print("Action: Check if these files are named correctly or if they are missing from the folder.")
        else:
            print("\n🎉 Perfect! All images referenced in the SQL exist in the folder.")

    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    file_map = create_extension_map(IMAGE_DIR)
    process_sql_file(file_map, SQL_INPUT_FILE, SQL_OUTPUT_FILE)