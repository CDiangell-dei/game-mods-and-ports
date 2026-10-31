import os, shutil, json, zipfile
from apk_v2_signer import sign_apk_v2

BASE_GAME_DIR = 'C:/Jogos/The Demon Lord\'s Lover'
WIN_DATA_DIR = os.path.join(BASE_GAME_DIR, 'the-demon-lords-lover-0.18.54-win_Data')
STREAMING_LOC_DIR = os.path.join(WIN_DATA_DIR, 'StreamingAssets', 'Localization')

SCRATCH_DIR = 'C:/Users/cield/.gemini/antigravity/brain/557bbb2c-03a4-422a-b9c5-99d6f059681b/scratch'
STRINGS_PT = os.path.join(SCRATCH_DIR, 'strings_pt.json')
GRAMMAR_PT = os.path.join(SCRATCH_DIR, 'grammar_pt.json')
SCENES_PT_DIR = os.path.join(SCRATCH_DIR, 'scenes_pt')

MANIFEST_DATA = {
    "code": "pt",
    "language": "Português (Brasil)",
    "name": "Português Brasileiro",
    "description": "Tradução completa para Português do Brasil (PT-BR) compatível com PC e Android.",
    "version": "0.18.54"
}

def install_windows():
    print("=== Installing Portuguese Translation for Windows ===")
    pt_pack_dir = os.path.join(STREAMING_LOC_DIR, 'pt')
    os.makedirs(pt_pack_dir, exist_ok=True)
    
    # 1. manifest.json
    manifest_path = os.path.join(pt_pack_dir, 'manifest.json')
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(MANIFEST_DATA, f, ensure_ascii=False, indent=2)
    print(f"Installed {manifest_path}")
    
    # 2. strings.json
    dest_strings = os.path.join(pt_pack_dir, 'strings.json')
    shutil.copyfile(STRINGS_PT, dest_strings)
    print(f"Installed {dest_strings}")
    
    # 3. grammar.json
    dest_grammar = os.path.join(pt_pack_dir, 'grammar.json')
    shutil.copyfile(GRAMMAR_PT, dest_grammar)
    print(f"Installed {dest_grammar}")
    
    # 4. scenes/
    dest_scenes = os.path.join(pt_pack_dir, 'scenes')
    if os.path.exists(dest_scenes):
        shutil.rmtree(dest_scenes)
    shutil.copytree(SCENES_PT_DIR, dest_scenes)
    print(f"Installed {dest_scenes} ({len(os.listdir(dest_scenes))} subdirectories)")
    
    # Also backup and update source/
    source_dir = os.path.join(STREAMING_LOC_DIR, 'source')
    source_backup = os.path.join(STREAMING_LOC_DIR, 'source_backup_en')
    if not os.path.exists(source_backup):
        print(f"Creating backup of English source at {source_backup}...")
        shutil.copytree(source_dir, source_backup)
        
    # Update source with PT-BR so default is Portuguese
    shutil.copyfile(STRINGS_PT, os.path.join(source_dir, 'strings.json'))
    shutil.copyfile(GRAMMAR_PT, os.path.join(source_dir, 'grammar.json'))
    dest_source_scenes = os.path.join(source_dir, 'scenes')
    shutil.rmtree(dest_source_scenes)
    shutil.copytree(SCENES_PT_DIR, dest_source_scenes)
    print("Updated source/ with PT-BR files as default!")
    
    # 5. External persistent translations directory
    appdata_loc = os.path.expanduser('~') + '/AppData/LocalLow/ayumu98/The Demon Lord\'s Lover/translations/pt'
    os.makedirs(appdata_loc, exist_ok=True)
    with open(os.path.join(appdata_loc, 'manifest.json'), 'w', encoding='utf-8') as f:
        json.dump(MANIFEST_DATA, f, ensure_ascii=False, indent=2)
    shutil.copyfile(STRINGS_PT, os.path.join(appdata_loc, 'strings.json'))
    shutil.copyfile(GRAMMAR_PT, os.path.join(appdata_loc, 'grammar.json'))
    appdata_scenes = os.path.join(appdata_loc, 'scenes')
    if os.path.exists(appdata_scenes):
        shutil.rmtree(appdata_scenes)
    shutil.copytree(SCENES_PT_DIR, appdata_scenes)
    print(f"Installed external translation pack in {appdata_loc}")
    
    # 6. Update settings file
    settings_path = os.path.expanduser('~') + '/AppData/LocalLow/ayumu98/The Demon Lord\'s Lover/0.6/save/settings'
    if os.path.exists(settings_path):
        try:
            with open(settings_path, 'r', encoding='utf-8-sig') as f:
                settings = json.load(f)
            settings['translation'] = 'pt'
            with open(settings_path, 'w', encoding='utf-8') as f:
                json.dump(settings, f, ensure_ascii=False, indent=2)
            print("Updated settings file: translation set to 'pt'")
        except Exception as e:
            print(f"Could not update settings file: {e}")
            
    print("Windows translation installation complete!\n")

def build_android_apk():
    print("=== Building Translated Android APK ===")
    orig_apk = os.path.join(BASE_GAME_DIR, 'the-demon-lords-lover-0.18.54-android.apk')
    backup_apk = os.path.join(BASE_GAME_DIR, 'the-demon-lords-lover-0.18.54-android.original.apk')
    if not os.path.exists(backup_apk):
        print(f"Backing up original APK to {backup_apk}...")
        shutil.copyfile(orig_apk, backup_apk)
        
    temp_unsigned = os.path.join(SCRATCH_DIR, 'temp_unsigned.apk')
    final_apk = os.path.join(BASE_GAME_DIR, 'the-demon-lords-lover-0.18.54-android-ptbr.apk')
    
    # Read files to inject
    with open(STRINGS_PT, 'rb') as f:
        strings_data = f.read()
    with open(GRAMMAR_PT, 'rb') as f:
        grammar_data = f.read()
    manifest_bytes = json.dumps(MANIFEST_DATA, ensure_ascii=False, indent=2).encode('utf-8')
    
    scenes_map = {}
    for root, dirs, files in os.walk(SCENES_PT_DIR):
        for file in files:
            if file.endswith('.scene'):
                p = os.path.join(root, file)
                rel = os.path.relpath(p, SCENES_PT_DIR).replace('\\', '/')
                with open(p, 'rb') as sf:
                    scenes_map[rel] = sf.read()
                    
    print(f"Injecting {len(scenes_map)} translated scenes, strings.json, and grammar.json into APK...")
    
    # Rebuild zip
    with zipfile.ZipFile(orig_apk, 'r') as zin, zipfile.ZipFile(temp_unsigned, 'w', compression=zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            # Skip old source files to replace them
            name = item.filename
            if name == 'assets/Localization/source/strings.json':
                zout.writestr(item, strings_data)
            elif name == 'assets/Localization/source/grammar.json':
                zout.writestr(item, grammar_data)
            elif name.startswith('assets/Localization/source/scenes/') and name[len('assets/Localization/source/scenes/'):] in scenes_map:
                rel = name[len('assets/Localization/source/scenes/'):]
                zout.writestr(item, scenes_map[rel])
            else:
                zout.writestr(item, zin.read(name))
                
        # Also add pt/ language pack inside APK
        zout.writestr('assets/Localization/pt/manifest.json', manifest_bytes)
        zout.writestr('assets/Localization/pt/strings.json', strings_data)
        zout.writestr('assets/Localization/pt/grammar.json', grammar_data)
        for rel, data in scenes_map.items():
            zout.writestr(f'assets/Localization/pt/scenes/{rel}', data)
            
    print("Repacked APK! Now signing with APK Signature Scheme v2...")
    sign_apk_v2(temp_unsigned, final_apk)
    
    if os.path.exists(temp_unsigned):
        os.remove(temp_unsigned)
        
    print(f"Successfully generated translated signed APK at: {final_apk} ({os.path.getsize(final_apk) / (1024*1024):.2f} MB)")
