import zipfile
import subprocess
import os
import shutil

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MGE_DIR = os.path.abspath(os.path.join(BASE_DIR, '..'))

base_apk = r'C:\Jogos\MGE\android\love-11.5-android-embed.apk'
game_love = r'C:\Jogos\MGE\game.love'
unaligned_apk = r'C:\Jogos\MGE\android\unaligned.apk'
aligned_apk = r'C:\Jogos\MGE\android\Monster_Girl_Encounters_PTBR.apk'
keystore = os.path.join(BASE_DIR, 'mge_release.keystore')

java_home = r'C:\Users\cield\AppData\Local\Packages\Microsoft.4297127D64EC6_8wekyb3d8bbwe\LocalCache\Local\runtime\java-runtime-epsilon\windows-x64\java-runtime-epsilon'
zipalign_bin = r'C:\Users\cield\AppData\Local\Android\Sdk\build-tools\34.0.0\zipalign.exe'
apksigner_bat = r'C:\Users\cield\AppData\Local\Android\Sdk\build-tools\34.0.0\apksigner.bat'

print("1. Creating unaligned APK with assets/game.love...")
if os.path.exists(unaligned_apk):
    os.remove(unaligned_apk)

with zipfile.ZipFile(base_apk, 'r') as src, zipfile.ZipFile(unaligned_apk, 'w') as dst:
    for item in src.infolist():
        if item.filename.startswith('META-INF/'):
            continue
        data = src.read(item.filename)
        dst.writestr(item, data)
    
    with open(game_love, 'rb') as f:
        love_bytes = f.read()
    dst.writestr('assets/game.love', love_bytes, compress_type=zipfile.ZIP_DEFLATED)

print(f"Unaligned APK created: {os.path.getsize(unaligned_apk)} bytes")

print("2. Running zipalign 4...")
if os.path.exists(aligned_apk):
    os.remove(aligned_apk)

align_cmd = [zipalign_bin, "-p", "-f", "4", unaligned_apk, aligned_apk]
res = subprocess.run(align_cmd, capture_output=True, text=True)
if res.returncode != 0:
    print("Zipalign error:", res.stderr)
    exit(1)
print(f"Aligned APK created: {os.path.getsize(aligned_apk)} bytes")

print("3. Signing with apksigner (v1, v2, v3)...")
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
print("apksigner output:", res.stdout)

print("4. Verifying APK signature...")
verify_cmd = [apksigner_bat, "verify", "--verbose", aligned_apk]
res = subprocess.run(verify_cmd, env=env, capture_output=True, text=True)
print("Verification result:\n" + res.stdout)

if os.path.exists(unaligned_apk):
    os.remove(unaligned_apk)

print(f"SUCCESS! Signed APK is ready at: {aligned_apk}")
