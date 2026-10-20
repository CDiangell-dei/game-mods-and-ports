import zipfile, os, shutil

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MGE_DIR = os.path.abspath(os.path.join(BASE_DIR, '..'))
src_dir = os.path.join(MGE_DIR, 'src')
if not os.path.exists(src_dir):
    src_dir = r'C:\Jogos\MGE\extracted'

output_love = r'C:\Jogos\MGE\game.love'
output_exe = r'C:\Jogos\MGE\MGE.exe'

# Read the 41984 byte stub from MGE.exe
with open(output_exe, 'rb') as f:
    stub = f.read(41984)

# Build game.love
with zipfile.ZipFile(output_love, 'w', zipfile.ZIP_DEFLATED) as z:
    for root, dirs, files in os.walk(src_dir):
        for f in files:
            if f.endswith('.orig') or f.endswith('.bak'):
                continue
            full_path = os.path.join(root, f)
            rel_path = os.path.relpath(full_path, src_dir).replace('\\', '/')
            z.write(full_path, rel_path)

print(f"Created {output_love}: {os.path.getsize(output_love)} bytes")

# Fuse stub + game.love -> MGE.exe
with open(output_love, 'rb') as f:
    love_data = f.read()

# Backup current MGE.exe
if os.path.exists(output_exe):
    shutil.copy2(output_exe, output_exe + '.bak')

with open(output_exe, 'wb') as f:
    f.write(stub)
    f.write(love_data)

print(f"Fused into {output_exe}: {os.path.getsize(output_exe)} bytes")
