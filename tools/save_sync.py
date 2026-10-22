import os
import shutil
import argparse
import sys

APPDATA_PATH = os.path.expandvars(r'%APPDATA%\monster_girl_encounters')
REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
MGE_SAVES_DIR = os.path.join(REPO_ROOT, 'games', 'nsfw', 'MGE', 'saves')

os.makedirs(MGE_SAVES_DIR, exist_ok=True)

def backup_pc_save():
    print(f"[*] Fazendo backup do save local do PC ({APPDATA_PATH})...")
    if not os.path.exists(APPDATA_PATH):
        print(f"[!] Pasta de save do PC não encontrada em {APPDATA_PATH}")
        return
    for fname in ['game.sav', 'settings.json']:
        src = os.path.join(APPDATA_PATH, fname)
        if os.path.exists(src):
            dst = os.path.join(MGE_SAVES_DIR, fname)
            shutil.copy2(src, dst)
            print(f"  [+] Copiado: {fname} -> {dst}")
    print("[✓] Backup concluído! Agora você pode fazer 'git add' e 'git commit' para salvar na nuvem.")

def restore_to_pc():
    print(f"[*] Restaurando save do repositório para o PC...")
    os.makedirs(APPDATA_PATH, exist_ok=True)
    for fname in ['game.sav', 'settings.json']:
        src = os.path.join(MGE_SAVES_DIR, fname)
        if os.path.exists(src):
            dst = os.path.join(APPDATA_PATH, fname)
            shutil.copy2(src, dst)
            print(f"  [+] Restaurado: {fname} -> {dst}")
    print("[✓] Restauração concluída! O jogo no PC carregará este progresso.")

def export_for_mobile(output_dir=None):
    if not output_dir:
        output_dir = os.path.join(REPO_ROOT, 'export_mobile_saves')
    os.makedirs(output_dir, exist_ok=True)
    print(f"[*] Exportando save para enviar ao celular em: {output_dir}")
    for fname in ['game.sav', 'settings.json']:
        src = os.path.join(MGE_SAVES_DIR, fname)
        if os.path.exists(src):
            shutil.copy2(src, os.path.join(output_dir, fname))
    print(f"[✓] Arquivos prontos na pasta {output_dir}.")
    print("    Caminho no Android (Love2D):")
    print("    /sdcard/Android/data/org.love2d.android/files/save/monster_girl_encounters/game.sav")

def main():
    parser = argparse.ArgumentParser(description="Sincronizador de Saves MGE (PC <-> Celular)")
    parser.add_argument('--backup', action='store_true', help="Copia save do PC para o repositório")
    parser.add_argument('--restore', action='store_true', help="Aplica o save do repositório no PC")
    parser.add_argument('--export', action='store_true', help="Exporta o save para enviar ao celular")
    args = parser.parse_args()

    if args.backup:
        backup_pc_save()
    elif args.restore:
        restore_to_pc()
    elif args.export:
        export_for_mobile()
    else:
        backup_pc_save()

if __name__ == '__main__':
    main()
