import os
import sys

# directories to search and the file extensions to look for
ROOT_DIRS = ['code/', 'interface/', 'maps/']
FILE_EXTENSIONS = ['.dm', '.dme', '.dmf']

# list of files or directories to ignore
IGNORE_LIST = [
    'code/modules/unit_tests/'
]

def is_ignored(file_path):
    for ignore in IGNORE_LIST:
        if file_path.startswith(ignore):
            return True
    return False

def find_unticked_files(dme_file):
    unticked_files = []
    ticked_files = set()
    try:
        with open(dme_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith("#define") or line.startswith("//"):
                    continue
                if line.startswith("#include"):
                    include_path = line.split('"')[1].replace('\\', '/')
                    ticked_files.add(include_path)
    except FileNotFoundError:
        print(f"Error: DME file '{dme_file}' not found.")
        sys.exit(1)

    for root_dir in ROOT_DIRS:
        for dirpath, _, filenames in os.walk(root_dir):
            for filename in filenames:
                for extension in FILE_EXTENSIONS:
                    if filename.endswith(extension):
                        file_path = os.path.join(dirpath, filename).replace('\\', '/')
                        if not is_ignored(file_path) and file_path not in ticked_files:
                            unticked_files.append(file_path)

    return unticked_files

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python check_for_unticked.py <path_to_dme_file>")
        sys.exit(1)

    dme_file = sys.argv[1]
    unticked_files = find_unticked_files(dme_file)

    if unticked_files:
        print("Unticked files found:")
        for file in unticked_files:
            print(f" - {file}")
    else:
        print("No unticked files found.")
