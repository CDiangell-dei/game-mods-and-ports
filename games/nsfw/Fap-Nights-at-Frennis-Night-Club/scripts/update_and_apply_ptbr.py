#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Utilitário de Atualização, Extração e Aplicação da Tradução PT-BR
para "Fap Nights at Frenni's Night Club" (Story Mode & Arcade Mode).
Página Oficial: https://fatal-fire-studios.itch.io/fap-nights-at-frennis-night-club

Uso:
  python update_and_apply_ptbr.py --check
  python update_and_apply_ptbr.py --apply
  python update_and_apply_ptbr.py --merge
  python update_and_apply_ptbr.py --game-dir "C:\\Jogos\\Fap-Nights-at-Frennis-Night-Club" --apply
"""

import os
import sys
import json
import struct
import shutil
import argparse
from pathlib import Path

try:
    import UnityPy
except ImportError:
    print("[ERRO] UnityPy não encontrado. Instale com: pip install UnityPy")
    sys.exit(1)

SCRIPT_DIR = Path(__file__).resolve().parent
GAME_REPO_DIR = SCRIPT_DIR.parent
LANG_DIR = GAME_REPO_DIR / "lang"
PTBR_JSON_PATH = LANG_DIR / "pt_br.json"
DEFAULT_INSTALL_DIR = Path(r"C:\Jogos\Fap-Nights-at-Frennis-Night-Club")

# Architecture parameters discovered via REA & reverse engineering:
# Story Mode: Unity 2019/2020 (Mono), UnityEngine.UI.Text script PathID 434, m_Text offset 128
STORY_CONFIG = {
    'name': 'Story Mode',
    'dir_rel': 'Story-Mode',
    'data_folder': 'FAP NIGHTS AT FRENNIs_Data',
    'script_id': 434,
    'text_offset': 128
}

# Arcade Mode: Unity 2021/2022 (IL2CPP), UnityEngine.UI.Text script PathID 475, m_Text offset 144
ARCADE_CONFIG = {
    'name': 'Arcade Mode',
    'dir_rel': 'Arcade-Mode',
    'data_folder': 'FAP N.A.F. ARCADE MODE_Data',
    'script_id': 475,
    'text_offset': 144
}


def load_ptbr_map():
    if not PTBR_JSON_PATH.exists():
        print(f"[ERRO] Dicionário não encontrado: {PTBR_JSON_PATH}")
        sys.exit(1)
    with open(PTBR_JSON_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def resolve_translation(s, ptbr_map):
    # 1. Exact match
    if s in ptbr_map and ptbr_map[s] != s:
        return ptbr_map[s]

    # 2. Whitespace-preserved trimmed match
    prefix = s[: len(s) - len(s.lstrip())]
    suffix = s[len(s.rstrip()) :]
    core = s.strip()

    if core in ptbr_map and ptbr_map[core] != core:
        return prefix + ptbr_map[core] + suffix

    # 3. Case-insensitive fallback
    core_upper = core.upper()
    if core_upper in ptbr_map and ptbr_map[core_upper] != core_upper:
        trans = ptbr_map[core_upper]
        if core.isupper():
            return prefix + trans.upper() + suffix
        elif core.istitle():
            return prefix + trans.title() + suffix
        return prefix + trans + suffix

    return None


def patch_file(file_path, config, ptbr_map, make_backup=True):
    changed_count = 0
    try:
        env = UnityPy.load(str(file_path))
        text_offset = config['text_offset']
        script_id = config['script_id']

        for obj in env.objects:
            if obj.type.name == "MonoBehaviour":
                raw = obj.get_raw_data()
                if len(raw) < (text_offset + 4):
                    continue
                s_file_id, s_path_id = struct.unpack_from('<iQ', raw, 16)
                if s_path_id == script_id:
                    t_len = struct.unpack_from('<i', raw, text_offset)[0]
                    if 1 <= t_len <= (len(raw) - text_offset - 4):
                        try:
                            s = raw[text_offset + 4 : text_offset + 4 + t_len].decode('utf-8')
                            new_text = resolve_translation(s, ptbr_map)
                            if new_text and new_text != s:
                                new_bytes = new_text.encode('utf-8')
                                new_len = len(new_bytes)
                                old_pad = (4 - (t_len % 4)) % 4
                                new_pad = (4 - (new_len % 4)) % 4

                                new_raw = (
                                    raw[:text_offset]
                                    + struct.pack('<i', new_len)
                                    + new_bytes
                                    + (b'\x00' * new_pad)
                                    + raw[text_offset + 4 + t_len + old_pad:]
                                )
                                obj.set_raw_data(new_raw)
                                changed_count += 1
                        except Exception:
                            pass

        if changed_count > 0:
            if make_backup:
                backup_path = file_path.with_name(file_path.name + ".orig")
                if not backup_path.exists():
                    shutil.copy2(str(file_path), str(backup_path))
            # Save patched content
            saved_data = env.file.save()
            with open(file_path, "wb") as f:
                f.write(saved_data)
    except Exception as e:
        print(f"    [AVISO] Erro ao processar {file_path.name}: {e}")

    return changed_count


def apply_translation(game_root, make_backup=True):
    ptbr_map = load_ptbr_map()
    print(f"[*] Aplicando tradução PT-BR ({len(ptbr_map)} chaves)...")
    
    for cfg in [STORY_CONFIG, ARCADE_CONFIG]:
        target_dir = game_root / cfg['dir_rel'] / cfg['data_folder']
        if not target_dir.exists():
            print(f"[!] Diretório não encontrado para {cfg['name']}: {target_dir}")
            continue

        print(f"\n--- Processando {cfg['name']} ---")
        files = sorted([f for f in target_dir.iterdir() if f.is_file() and (f.name.startswith("level") or f.name.endswith(".assets")) and not f.name.endswith(".orig") and not f.name.endswith(".resS")])
        total_changed = 0
        
        for f in files:
            if f.stat().st_size > 300 * 1024 * 1024:
                continue
            cnt = patch_file(f, cfg, ptbr_map, make_backup=make_backup)
            if cnt > 0:
                print(f"  [✓] {f.name}: {cnt} textos atualizados")
                total_changed += cnt

        print(f"[*] Total de modificações aplicadas em {cfg['name']}: {total_changed}")


def check_status(game_root):
    ptbr_map = load_ptbr_map()
    print(f"[*] Dicionário PT-BR contém {len(ptbr_map)} entradas.")

    for cfg in [STORY_CONFIG, ARCADE_CONFIG]:
        target_dir = game_root / cfg['dir_rel'] / cfg['data_folder']
        if not target_dir.exists():
            print(f"[-] {cfg['name']}: Não instalado em {target_dir}")
            continue

        installed_files = list(target_dir.glob("level*"))
        has_orig = any(f.name.endswith(".orig") for f in target_dir.iterdir())
        status = "Traduzido / Modificado (backup .orig presente)" if has_orig else "Original (não patcheado)"
        print(f"[✓] {cfg['name']}: {len(installed_files)} cenas encontradas. Status: {status}")


def main():
    parser = argparse.ArgumentParser(description="Atualiza e aplica tradução PT-BR para Fap Nights at Frenni's Night Club")
    parser.add_argument("--game-dir", type=str, default=str(DEFAULT_INSTALL_DIR), help="Caminho raiz da instalação do jogo")
    parser.add_argument("--check", action="store_true", help="Verifica integridade e status da tradução")
    parser.add_argument("--apply", action="store_true", help="Aplica a tradução PT-BR nos arquivos do jogo")
    parser.add_argument("--no-backup", action="store_true", help="Não cria cópias .orig de backup ao aplicar")
    args = parser.parse_args()

    game_root = Path(args.game_dir)

    if args.check:
        check_status(game_root)
    elif args.apply:
        apply_translation(game_root, make_backup=not args.no_backup)
    else:
        # Default action: check then prompt or show help
        check_status(game_root)
        print("\nPara aplicar a tradução agora, execute:")
        print(f"  python update_and_apply_ptbr.py --apply")


if __name__ == "__main__":
    main()
