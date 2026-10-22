import zipfile
import subprocess
import os
import shutil
import struct
import hashlib
import zlib

base_apk = r'C:\Jogos\MGE\android\love-11.5-android.apk'
game_love = r'C:\Jogos\MGE\game.love'
unaligned_apk = r'C:\Jogos\MGE\android\unaligned.apk'
aligned_apk = r'C:\Jogos\MGE\android\Monster_Girl_Encounters_PTBR.apk'
keystore = r'C:\Jogos\MGE\android\mge_release.keystore'

java_home = r'C:\Users\cield\AppData\Local\Packages\Microsoft.4297127D64EC6_8wekyb3d8bbwe\LocalCache\Local\runtime\java-runtime-epsilon\windows-x64\java-runtime-epsilon'
zipalign_bin = r'C:\Users\cield\AppData\Local\Android\Sdk\build-tools\34.0.0\zipalign.exe'
apksigner_bat = r'C:\Users\cield\AppData\Local\Android\Sdk\build-tools\34.0.0\apksigner.bat'

print("1. Patching classes.dex to enable embedded game loading (embed=true, needToCopy=true)...")
with zipfile.ZipFile(base_apk, 'r') as src:
    dex = bytearray(src.read('classes.dex'))

# Find target instruction pattern: invoke-virtual getBoolean; move-result v1; iput-boolean v1, embed
pattern = bytes.fromhex('6e20370221000a015c31d20d6a01d70d')
idx = dex.find(pattern)
if idx != -1:
    patch_pos = idx + 6 # offset of 0a01 (move-result v1)
    dex[patch_pos] = 0x12     # const/4
    dex[patch_pos + 1] = 0x11 # v1, 1 (true)
    # Recalculate SHA-1
    dex[12:32] = hashlib.sha1(dex[32:]).digest()
    # Recalculate Adler-32
    dex[8:12] = struct.pack('<I', zlib.adler32(dex[12:]) & 0xffffffff)
    print(f"   Successfully patched classes.dex at {hex(patch_pos)}!")
else:
    print("   WARNING: Patch pattern not found in classes.dex!")

print("2. Packaging unaligned APK with assets/game.love and patched classes.dex...")
if os.path.exists(unaligned_apk):
    os.remove(unaligned_apk)

with zipfile.ZipFile(base_apk, 'r') as src, zipfile.ZipFile(unaligned_apk, 'w') as dst:
    for item in src.infolist():
        if item.filename.startswith('META-INF/'):
            continue
        if item.filename == 'classes.dex':
            # Write our patched DEX with identical compression
            dst.writestr(item, bytes(dex))
            continue
        data = src.read(item.filename)
        dst.writestr(item, data)
    
    # Add game.love into assets/
    with open(game_love, 'rb') as f:
        love_bytes = f.read()
    dst.writestr('assets/game.love', love_bytes, compress_type=zipfile.ZIP_DEFLATED)

print(f"   Unaligned APK created: {os.path.getsize(unaligned_apk)} bytes")

print("3. Running zipalign -p -f 4...")
if os.path.exists(aligned_apk):
    os.remove(aligned_apk)

align_cmd = [zipalign_bin, "-p", "-f", "4", unaligned_apk, aligned_apk]
res = subprocess.run(align_cmd, capture_output=True, text=True)
if res.returncode != 0:
    print("Zipalign error:", res.stderr)
    exit(1)
print(f"   Aligned APK created: {os.path.getsize(aligned_apk)} bytes")

print("4. Signing with apksigner (v1, v2, v3)...")
env = os.environ.copy()
env['JAVA_HOME'] = java_home
env['PATH'] = os.path.join(java_home, 'bin') + os.pathsep + env.get('PATH', '')

sign_cmd = [
    apksigner_bat,
    "sign",
    "--ks", keystore,
    "--ks-key-alias", "mge",
    "--ks-pass", "pass:android",
    "--key-pass", "pass:android",
    "--v1-signing-enabled", "true",
    "--v2-signing-enabled", "true",
    "--v3-signing-enabled", "true",
    aligned_apk
]
res = subprocess.run(sign_cmd, env=env, capture_output=True, text=True)
if res.returncode != 0:
    print("apksigner error:", res.stderr)
    exit(1)

print("5. Verifying APK signature...")
verify_cmd = [apksigner_bat, "verify", "--verbose", aligned_apk]
res = subprocess.run(verify_cmd, env=env, capture_output=True, text=True)
print("Verification result:\n" + res.stdout)
if res.stderr:
    print("Verification stderr:\n" + res.stderr)

if os.path.exists(unaligned_apk):
    os.remove(unaligned_apk)

print(f"SUCCESS! Signed standalone embedded APK ready at: {aligned_apk}")
