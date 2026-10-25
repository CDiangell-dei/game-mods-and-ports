#!/usr/bin/env python3
"""
build_standalone_muffet.py
==========================
Builds the standalone Muffet edition of Adulttale ("Adulttale - Luta da Muffet")
by applying binary patches (discovered via REA static analysis of the GameMaker
Studio 2023+ YYC x86_64 PE executable `Adulttale.exe`) and PT-BR localization.

Features of the Standalone Muffet Edition:
1. "Lutar com Muffet" (New Game -> Yes):
   Jumps directly from `anon@7098@gml_Object_obj_gui_menu_Create_0` (RVA 0x26d7e0)
   to `anon@18@gml_Object_obj_prop_interact_Create_0` (RVA 0x2d4bb0), patched to call:
     `battle_start("muffet_fight", [427.0, 224.0], 0, "muffet_fight")`
   with `global.muffet_fight_init = false` (0.0) so the full Muffet Boss Battle
   (intro dialogue, phases, Shadow Rabbit, Chara help, etc.) starts immediately.
2. "Clube da Muffet" (Continue):
   Loads the pre-configured save (`global_save_0.ini` with `charas_promise` and
   healing items) and spawns the player directly in `rm_strip_enter` (Room 26,
   Muffet's Club Entrance) right in front of Muffet, the Save Star, the Bed, and
   the Club Hallway (`rm_strip_hallway`, Room 27) for unlimited replays.
3. Defeat & Exit Handling:
   - Losing the Muffet battle respawns the player in `rm_strip_enter` (Room 26)
     in front of Muffet instead of an empty LoadSave screen.
   - Walking out the left exit door of `rm_strip_enter` returns cleanly to the
     Main Menu (`rm_mainmenu_new`, Room 14) instead of Hotland.
"""

import argparse
import json
import os
import shutil
from pathlib import Path


def rva_to_raw(rva: int) -> int:
    """Convert .text RVA (VA=0x1000, Raw=0x400) to file offset in Adulttale.exe."""
    return rva - 0x1000 + 0x400


def patch_executable(src_exe: Path, dst_exe: Path) -> None:
    pe = bytearray(src_exe.read_bytes())

    # Room 26 (0x1a = rm_strip_enter) assignment sequence (48 bytes = 0x30 bytes):
    #   48 b8 1a 00 00 00 03 00 00 01   mov rax, 0x010000030000001a
    #   48 89 85 a0 00 00 00            mov [rbp+0xa0], rax
    #   c7 85 ac 00 00 00 0f 00 00 00   mov dword ptr [rbp+0xac], 0x0f (VALUE_REF)
    #   48 8d 85 a0 00 00 00            lea rax, [rbp+0xa0]
    #   90 * 14                         14 NOPs
    force_room_26_48b = bytes.fromhex(
        "48 b8 1a 00 00 00 03 00 00 01 "
        "48 89 85 a0 00 00 00 "
        "c7 85 ac 00 00 00 0f 00 00 00 "
        "48 8d 85 a0 00 00 00 "
        + ("90 " * 14).strip()
    )
    assert len(force_room_26_48b) == 48

    patches = [
        # 1. New Game -> Yes (RVA 0x26d7e0): jmp 0x2d4bb0
        (
            "New Game -> Yes direct jump to Muffet battle_start",
            0x26D7E0,
            bytes.fromhex("48 89 5c 24 08"),
            bytes.fromhex("e9 2b 74 06 00"),
        ),
        # 2. prop_interact battle_start arg3 (RVA 0x2d4cd2): lea rdx, [0x11a6aa8] ("muffet_fight")
        (
            "battle_start arg3 = 'muffet_fight'",
            0x2D4CD2,
            bytes.fromhex("48 8d 15 07 1b b2 00"),
            bytes.fromhex("48 8d 15 cf 1d ed 00"),
        ),
        # 3. prop_interact global.muffet_fight_init = false (0.0) (RVA 0x2d4d15): xorps xmm0, xmm0 + 4 NOPs
        (
            "global.muffet_fight_init = false (full boss fight)",
            0x2D4D15,
            bytes.fromhex("0f 10 05 54 fd 94 00"),
            bytes.fromhex("0f 57 c0 90 90 90 90"),
        ),
        # 4. Continue fallback room when no save exists (RVA 0x26a2a0): rm_strip_enter (0x1a)
        (
            "Continue fallback room -> rm_strip_enter (0x1a)",
            0x26A2A0,
            bytes.fromhex("48 b8 0d 00 00 00 03 00 00 01"),
            bytes.fromhex("48 b8 1a 00 00 00 03 00 00 01"),
        ),
        # 5. SaveManager load room #1 (RVA 0x3302a1, 48 bytes): force rm_strip_enter (0x1a)
        (
            "SaveManager load slot room #1 -> rm_strip_enter (0x1a)",
            0x3302A1,
            bytes.fromhex(
                "48 8d 45 b8 48 89 44 24 28 8b 05 68 d9 ac 00 89 44 24 20 "
                "45 8b cc 4c 8d 85 a0 00 00 00 48 8b 95 68 09 00 00 "
                "48 8b 8d 60 09 00 00 e8 af 10 19 00"
            ),
            force_room_26_48b,
        ),
        # 6. SaveManager load room #2 (RVA 0x334094, 48 bytes): force rm_strip_enter (0x1a)
        (
            "SaveManager load slot room #2 -> rm_strip_enter (0x1a)",
            0x334094,
            bytes.fromhex(
                "48 8d 45 b8 48 89 44 24 28 8b 05 75 9b ac 00 89 44 24 20 "
                "45 8b cc 4c 8d 85 a0 00 00 00 48 8b 95 68 09 00 00 "
                "48 8b 8d 60 09 00 00 e8 bc d2 18 00"
            ),
            force_room_26_48b,
        ),
        # 7. Muffet fight player death respawn room (RVA 0x3fd778): rm_strip_enter (0x1a)
        (
            "Muffet defeat respawn room -> rm_strip_enter (0x1a)",
            0x3FD778,
            bytes.fromhex("48 b8 03 00 00 00 03 00 00 01"),
            bytes.fromhex("48 b8 1a 00 00 00 03 00 00 01"),
        ),
        # 8. Strip club left exit door (RVA 0x182359): return to Main Menu (rm_mainmenu_new = 0x0e)
        (
            "rm_strip_enter left exit door -> rm_mainmenu_new (0x0e)",
            0x182359,
            bytes.fromhex("48 b8 0c 00 00 00 03 00 00 01"),
            bytes.fromhex("48 b8 0e 00 00 00 03 00 00 01"),
        ),
    ]

    for desc, rva, orig_bytes, new_bytes in patches:
        raw = rva_to_raw(rva)
        assert len(orig_bytes) == len(new_bytes), f"Length mismatch for {desc}"
        current = bytes(pe[raw : raw + len(orig_bytes)])
        if current == orig_bytes:
            pe[raw : raw + len(new_bytes)] = new_bytes
            print(f"[PATCHED] {desc} @ RVA 0x{rva:x} (raw 0x{raw:x})")
        elif current == new_bytes:
            print(f"[ALREADY PATCHED] {desc} @ RVA 0x{rva:x} (raw 0x{raw:x})")
        else:
            raise RuntimeError(
                f"Unexpected bytes for {desc} @ RVA 0x{rva:x}: {current.hex(' ')}"
            )

    dst_exe.parent.mkdir(parents=True, exist_ok=True)
    dst_exe.write_bytes(pe)
    print(f"[OK] Wrote patched executable to {dst_exe}")


def build_standalone_lang(pt_json_path: Path, dst_lang_dir: Path) -> None:
    dst_lang_dir.mkdir(parents=True, exist_ok=True)
    with open(pt_json_path, "r", encoding="utf-8-sig") as f:
        data = json.load(f)

    # Customize Main Menu labels for the standalone Muffet edition
    data["lang_main_menu_newgame_name"] = "Lutar com Muffet"
    data["lang_main_menu_continue_name"] = "Clube da Muffet"
    data["lang_main_menu_option_lang_eng"] = "Português (BR)"
    data["lang_main_menu_option_lang_rus"] = "Português (BR)"

    out_text = json.dumps(data, ensure_ascii=False, indent=2)
    for fname in ("eng.json", "esp.json", "pt.json", "rus.json"):
        (dst_lang_dir / fname).write_text(out_text, encoding="utf-8")
    print(f"[OK] Wrote standalone PT-BR language files to {dst_lang_dir}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Build Adulttale Standalone Muffet Edition")
    parser.add_argument(
        "--source-dir",
        type=Path,
        default=Path(r"C:\Jogos\Adulttale"),
        help="Path to the original Adulttale directory",
    )
    parser.add_argument(
        "--target-dir",
        type=Path,
        default=Path(r"C:\Jogos\Adulttale-Muffet"),
        help="Path to output the standalone Muffet game directory",
    )
    parser.add_argument(
        "--saves-dir",
        type=Path,
        default=Path(r"C:\Jogos\game-mods-and-ports\games\nsfw\Adulttale\saves"),
        help="Path to the pre-configured Adulttale saves directory",
    )
    args = parser.parse_args()

    src = args.source_dir
    dst = args.target_dir
    dst.mkdir(parents=True, exist_ok=True)

    # Copy core assets
    for asset in ("data.win", "Moans.dat", "Music.dat", "SFX.dat", "Squishes.dat"):
        s_file = src / asset
        d_file = dst / asset
        if not d_file.exists() or s_file.stat().st_size != d_file.stat().st_size:
            print(f"[COPY] {s_file.name} -> {dst}")
            shutil.copy2(s_file, d_file)

    # Patch Adulttale.exe
    patch_executable(src / "Adulttale.exe", dst / "Adulttale.exe")

    # Build standalone PT-BR lang files
    pt_src = src / "lang" / "pt.json"
    if not pt_src.exists():
        pt_src = src / "lang" / "esp.json"
    build_standalone_lang(pt_src, dst / "lang")

    # Copy saves to target-dir/saves and %LOCALAPPDATA%/Adulttale
    if args.saves_dir.exists():
        dst_saves = dst / "saves"
        dst_saves.mkdir(parents=True, exist_ok=True)
        for item in args.saves_dir.iterdir():
            if item.is_file():
                shutil.copy2(item, dst_saves / item.name)
        local_appdata = os.environ.get("LOCALAPPDATA")
        if local_appdata:
            appdata_dir = Path(local_appdata) / "Adulttale"
            appdata_dir.mkdir(parents=True, exist_ok=True)
            for item in args.saves_dir.iterdir():
                if item.is_file():
                    shutil.copy2(item, appdata_dir / item.name)
            print(f"[OK] Installed Muffet save & settings to {appdata_dir}")


if __name__ == "__main__":
    main()
