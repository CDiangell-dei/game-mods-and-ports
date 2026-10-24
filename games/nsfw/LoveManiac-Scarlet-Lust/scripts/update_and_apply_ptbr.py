#!/usr/bin/env python3
"""
Script de atualização e aplicação da tradução PT-BR para LoveManiac: Scarlet Lust.
Engine: TurboWarp / PenguinMod (WebView2) -> www/assets/project.json

Uso:
  python update_and_apply_ptbr.py --check
  python update_and_apply_ptbr.py --merge
  python update_and_apply_ptbr.py --apply
  python update_and_apply_ptbr.py --game-dir "C:\\Jogos\\LoveManiac-Scarlet-Lust" --merge --apply
"""

import argparse
import json
import shutil
import sys
from pathlib import Path

REPO_GAME_DIR = Path(__file__).resolve().parent.parent
REPO_LANG_DIR = REPO_GAME_DIR / "lang"
DEFAULT_INSTALL_DIR = Path(r"C:\Jogos\LoveManiac-Scarlet-Lust")

DIALOG_LIST_ID = "dF{5|W6`[c/nX[O53.t2"
LANGUAGE_VAR_ID = "1z2Yh4{R$(cK?Cm%WM:("


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def save_json(path: Path, data: dict, compact: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        if compact:
            json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
        else:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")


def get_source_project_path(game_dir: Path) -> Path:
    orig = game_dir / "www" / "assets" / "project.json.orig"
    curr = game_dir / "www" / "assets" / "project.json"
    return orig if orig.exists() else curr


def get_dialog_list(stage: dict) -> list:
    for list_id, list_pair in stage.get("lists", {}).items():
        if isinstance(list_pair, list) and len(list_pair) >= 2 and list_pair[0] == "Dialog":
            return list_pair[1]
    raise KeyError("Lista 'Dialog' não encontrada no Stage de project.json")


def extract_reference(project_data: dict) -> dict:
    stage = next(t for t in project_data["targets"] if t["isStage"])
    dialog_list = get_dialog_list(stage)
    pairs = {}
    for i in range(0, len(dialog_list), 2):
        idx_str = str(i + 1)
        en_line = dialog_list[i]
        es_line = dialog_list[i + 1] if i + 1 < len(dialog_list) else ""
        pairs[idx_str] = {"en": en_line, "es": es_line}
    return {"dialog_count": len(dialog_list), "dialog_pairs": pairs}


def check_and_merge(game_dir: Path, do_merge: bool = False) -> int:
    src_proj = get_source_project_path(game_dir)
    if not src_proj.exists():
        print(f"[ERRO] Arquivo project.json não encontrado em: {src_proj}")
        return 1

    proj_data = load_json(src_proj)
    ref_data = extract_reference(proj_data)

    ref_path = REPO_LANG_DIR / "en_es_reference.json"
    pt_path = REPO_LANG_DIR / "pt_br.json"

    if not ref_path.exists() or do_merge:
        save_json(ref_path, ref_data)

    pt_data = load_json(pt_path)
    pt_pairs = pt_data.get("dialog_pairs", {})

    new_keys = []
    changed_keys = []
    old_ref = load_json(ref_path).get("dialog_pairs", {}) if ref_path.exists() else {}

    for idx_str, pair in ref_data["dialog_pairs"].items():
        if idx_str not in pt_pairs:
            new_keys.append((idx_str, pair["en"], pair["es"]))
        elif idx_str in old_ref and old_ref[idx_str].get("en") != pair["en"]:
            changed_keys.append((idx_str, old_ref[idx_str].get("en"), pair["en"]))

    print("=== Status da Tradução PT-BR (LoveManiac: Scarlet Lust) ===")
    print(f"Total de pares de diálogo no jogo : {len(ref_data['dialog_pairs'])}")
    print(f"Total de pares traduzidos (PT-BR) : {len(pt_pairs)}")
    print(f"Blocos de UI mapeados (PT-BR)     : {len(pt_data.get('ui_blocks', {}))}")
    print(f"Novas linhas de diálogo           : {len(new_keys)}")
    print(f"Linhas alteradas no original      : {len(changed_keys)}")

    if do_merge and new_keys:
        for idx_str, en_val, es_val in new_keys:
            pt_pairs[idx_str] = f"[TODO_PTBR] {en_val}"
        pt_data["dialog_pairs"] = pt_pairs
        save_json(pt_path, pt_data)
        print(f"[OK] {len(new_keys)} novas linhas adicionadas em {pt_path}")

    return 0


def apply_translation(game_dir: Path) -> int:
    proj_path = game_dir / "www" / "assets" / "project.json"
    orig_path = game_dir / "www" / "assets" / "project.json.orig"

    if not proj_path.exists():
        print(f"[ERRO] Arquivo do jogo não encontrado: {proj_path}")
        return 1

    if not orig_path.exists():
        shutil.copy2(proj_path, orig_path)
        print(f"[BACKUP] Backup original salvo em: {orig_path}")

    proj_data = load_json(orig_path)
    pt_data = load_json(REPO_LANG_DIR / "pt_br.json")
    pt_pairs = pt_data.get("dialog_pairs", {})
    ui_blocks = pt_data.get("ui_blocks", {})

    # 1. Atualiza a lista Dialog no Stage (preenche slots ímpares [EN] e pares [ES] com PT-BR)
    stage = next(t for t in proj_data["targets"] if t["isStage"])
    dialog_list = get_dialog_list(stage)
    updated_dialogs = 0
    for idx_str, pt_text in pt_pairs.items():
        i = int(idx_str) - 1
        if 0 <= i < len(dialog_list):
            dialog_list[i] = pt_text
            if i + 1 < len(dialog_list):
                dialog_list[i + 1] = pt_text
            updated_dialogs += 1

    # 2. Atualiza textos de UI nos blocos de todos os targets
    updated_ui = 0
    for target in proj_data["targets"]:
        blocks = target.get("blocks", {})
        for b in blocks.values():
            if not isinstance(b, dict):
                continue
            inputs = b.get("inputs", {})
            for inp in inputs.values():
                if (
                    isinstance(inp, list)
                    and len(inp) >= 2
                    and isinstance(inp[1], list)
                    and len(inp[1]) >= 2
                    and inp[1][0] == 10
                ):
                    orig_val = inp[1][1]
                    if orig_val in ui_blocks:
                        inp[1][1] = ui_blocks[orig_val]
                        updated_ui += 1

    save_json(proj_path, proj_data, compact=True)
    print(f"[APLICADO] {updated_dialogs} pares de diálogo e {updated_ui} blocos de UI traduzidos em: {proj_path}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Gerenciador de tradução PT-BR do LoveManiac: Scarlet Lust")
    parser.add_argument("--game-dir", type=Path, default=DEFAULT_INSTALL_DIR, help="Pasta de instalação do jogo")
    parser.add_argument("--check", action="store_true", help="Verifica diferenças entre o jogo e a tradução")
    parser.add_argument("--merge", action="store_true", help="Mescla novas linhas no pt_br.json")
    parser.add_argument("--apply", action="store_true", help="Aplica a tradução PT-BR no jogo instalado")

    args = parser.parse_args()
    if not (args.check or args.merge or args.apply):
        args.check = True

    rc = 0
    if args.check or args.merge:
        rc = check_and_merge(args.game_dir, do_merge=args.merge)
        if rc != 0:
            return rc

    if args.apply:
        rc = apply_translation(args.game_dir)

    return rc


if __name__ == "__main__":
    sys.exit(main())
