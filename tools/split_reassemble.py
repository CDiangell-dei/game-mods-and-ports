#!/usr/bin/env python3
"""
Utilitário para dividir e remontar arquivos >95 MB do repositório (limite de 100 MB do GitHub),
mantendo os arquivos originais intactos localmente para que os jogos funcionem direto da pasta.

Uso:
  python tools/split_reassemble.py --split       # Gera partes .part00, .part01... para arquivos >95 MB
  python tools/split_reassemble.py --reassemble  # Remonta os arquivos originais a partir das partes .part*
"""

import argparse
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CHUNK_SIZE = 80 * 1024 * 1024  # 80 MB por parte
LARGE_FILES = [
    REPO_ROOT / "games" / "nsfw" / "Adulttale" / "Squishes.dat",
    REPO_ROOT / "games" / "nsfw" / "Adulttale-Muffet" / "Squishes.dat",
    REPO_ROOT / "games" / "nsfw" / "LoveManiac" / "LoveManiac 0.3.6.pck",
]


def split_file(file_path: Path) -> None:
    if not file_path.exists():
        print(f"[AVISO] Arquivo não encontrado para dividir: {file_path}")
        return

    # Remove partes antigas se existirem
    for old_part in file_path.parent.glob(file_path.name + ".part*"):
        old_part.unlink()

    idx = 0
    with file_path.open("rb") as src:
        while True:
            chunk = src.read(CHUNK_SIZE)
            if not chunk:
                break
            part_path = file_path.with_name(f"{file_path.name}.part{idx:02d}")
            part_path.write_bytes(chunk)
            print(f"[SPLIT] Criado: {part_path.relative_to(REPO_ROOT)} ({len(chunk) / (1024*1024):.2f} MB)")
            idx += 1


def reassemble_file(file_path: Path) -> None:
    parts = sorted(file_path.parent.glob(file_path.name + ".part*"))
    if not parts:
        print(f"[AVISO] Nenhuma parte encontrada para: {file_path}")
        return

    with file_path.open("wb") as dst:
        for p in parts:
            dst.write(p.read_bytes())
    print(f"[REASSEMBLE] Remontado: {file_path.relative_to(REPO_ROOT)} ({file_path.stat().st_size / (1024*1024):.2f} MB)")


def main() -> int:
    parser = argparse.ArgumentParser(description="Divide ou remonta arquivos >95 MB para o GitHub")
    parser.add_argument("--split", action="store_true", help="Gera partes de 80 MB para o Git")
    parser.add_argument("--reassemble", action="store_true", help="Remonta os arquivos completos após git clone")
    args = parser.parse_args()

    if args.reassemble:
        for fp in LARGE_FILES:
            reassemble_file(fp)
    else:
        for fp in LARGE_FILES:
            split_file(fp)
    return 0


if __name__ == "__main__":
    sys.exit(main())
