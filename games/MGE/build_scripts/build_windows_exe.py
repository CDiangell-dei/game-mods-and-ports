import os
import zipfile
import shutil

extracted_dir = 'C:/Jogos/MGE/extracted'
game_love_path = 'C:/Jogos/MGE/game.love'
launcher_path = 'C:/Jogos/MGE/love_launcher.exe'
mge_exe_path = 'C:/Jogos/MGE/MGE.exe'
android_love_path = 'C:/Jogos/MGE/android/game.love'

print("1. Creating game.love from extracted/...")
with zipfile.ZipFile(game_love_path, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as z:
    for root, dirs, files in os.walk(extracted_dir):
        for f in files:
            full_path = os.path.join(root, f)
            rel_path = os.path.relpath(full_path, extracted_dir).replace('\\', '/')
            z.write(full_path, rel_path)

print(f"   game.love created: {os.path.getsize(game_love_path)} bytes")

print("2. Fusing love_launcher.exe + game.love -> MGE.exe...")
with open(launcher_path, 'rb') as f_stub:
    stub = f_stub.read()

with open(game_love_path, 'rb') as f_love:
    love_data = f_love.read()

with open(mge_exe_path, 'wb') as f_out:
    f_out.write(stub)
    f_out.write(love_data)

print(f"   MGE.exe created: {os.path.getsize(mge_exe_path)} bytes")

print("3. Updating android/game.love...")
shutil.copy2(game_love_path, android_love_path)
print("   Updated android/game.love successfully!")
