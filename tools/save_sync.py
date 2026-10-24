import os
import shutil
import argparse
import sys

GAMES_CONFIG = {
    'mge': {
        'name': 'Monster Girl Encounters (MGE)',
        'pc_dir': os.path.expandvars(r'%APPDATA%\monster_girl_encounters'),
        'repo_dir': os.path.join('games', 'nsfw', 'MGE', 'saves'),
        'files': ['game.sav', 'settings.json'],
        'android_hint': '/sdcard/Android/data/org.love2d.android/files/save/monster_girl_encounters/game.sav'
    },
    'adulttale': {
        'name': 'Adulttale',
        'pc_dir': os.path.expandvars(r'%LOCALAPPDATA%\Adulttale'),
        'repo_dir': os.path.join('games', 'nsfw', 'Adulttale', 'saves'),
        'files': ['all', 'global_save_0.ini', 'settings.ini', 'pause_screen.png'],
        'android_hint': '/sdcard/Android/data/com.adulttale.game/files/'
    },
    'lovemaniac': {
        'name': 'LoveManiac',
        'pc_dir': os.path.expandvars(r'%APPDATA%\Godot\app_userdata\Love Maniac\save'),
        'repo_dir': os.path.join('games', 'nsfw', 'LoveManiac', 'saves'),
        'files': ['meta.json', 'slot_0.json', 'slot_1.json', 'slot_2.json'],
        'android_hint': '/sdcard/Android/data/com.teamnebula.lovemaniac/files/save/'
    }
}

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))


def get_targets(game_arg):
    if game_arg == 'all':
        return list(GAMES_CONFIG.keys())
    return [game_arg]


def backup_pc_save(game_key):
    cfg = GAMES_CONFIG[game_key]
    pc_dir = cfg['pc_dir']
    repo_dir = os.path.join(REPO_ROOT, cfg['repo_dir'])
    os.makedirs(repo_dir, exist_ok=True)

    print(f"[*] [{cfg['name']}] Fazendo backup do save local do PC ({pc_dir})...")
    if not os.path.exists(pc_dir):
        print(f"  [!] Pasta de save do PC não encontrada em {pc_dir}")
        return
    for fname in cfg['files']:
        src = os.path.join(pc_dir, fname)
        if os.path.exists(src):
            dst = os.path.join(repo_dir, fname)
            shutil.copy2(src, dst)
            print(f"  [+] Copiado: {fname} -> {dst}")
    print(f"[✓] [{cfg['name']}] Backup concluído!")


def restore_to_pc(game_key):
    cfg = GAMES_CONFIG[game_key]
    pc_dir = cfg['pc_dir']
    repo_dir = os.path.join(REPO_ROOT, cfg['repo_dir'])

    print(f"[*] [{cfg['name']}] Restaurando save do repositório para o PC ({pc_dir})...")
    os.makedirs(pc_dir, exist_ok=True)
    for fname in cfg['files']:
        src = os.path.join(repo_dir, fname)
        if os.path.exists(src):
            dst = os.path.join(pc_dir, fname)
            shutil.copy2(src, dst)
            print(f"  [+] Restaurado: {fname} -> {dst}")
    print(f"[✓] [{cfg['name']}] Restauração concluída!")


def export_for_mobile(game_key, output_dir=None):
    cfg = GAMES_CONFIG[game_key]
    repo_dir = os.path.join(REPO_ROOT, cfg['repo_dir'])
    if not output_dir:
        output_dir = os.path.join(REPO_ROOT, 'export_mobile_saves', game_key)
    os.makedirs(output_dir, exist_ok=True)

    print(f"[*] [{cfg['name']}] Exportando save para enviar ao celular em: {output_dir}")
    for fname in cfg['files']:
        src = os.path.join(repo_dir, fname)
        if os.path.exists(src):
            shutil.copy2(src, os.path.join(output_dir, fname))
    print(f"[✓] Arquivos prontos na pasta {output_dir}.")
    print(f"    Caminho referência no Android: {cfg['android_hint']}")


def main():
    parser = argparse.ArgumentParser(description="Sincronizador de Saves (PC <-> Repositório <-> Celular)")
    parser.add_argument('--game', choices=['all', 'mge', 'adulttale', 'lovemaniac'], default='all', help="Jogo alvo (padrão: all)")
    parser.add_argument('--backup', action='store_true', help="Copia save do PC para o repositório")
    parser.add_argument('--restore', action='store_true', help="Aplica o save do repositório no PC")
    parser.add_argument('--export', action='store_true', help="Exporta o save para enviar ao celular")
    args = parser.parse_args()

    targets = get_targets(args.game)
    for g in targets:
        if args.backup:
            backup_pc_save(g)
        elif args.restore:
            restore_to_pc(g)
        elif args.export:
            export_for_mobile(g)
        else:
            backup_pc_save(g)


if __name__ == '__main__':
    main()
