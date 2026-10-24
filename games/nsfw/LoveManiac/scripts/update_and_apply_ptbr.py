#!/usr/bin/env python3
"""
Script de atualização, mesclagem e aplicação da tradução PT-BR para LoveManiac (Godot 4.5 PCK v3).
Decodifica e reconstrói recursos binários OptimizedTranslation (RSRC / RSCC + Zstandard + Smaz)
diretamente no arquivo .pck da versão mais recente instalada.

Uso:
  python update_and_apply_ptbr.py --check
  python update_and_apply_ptbr.py --merge
  python update_and_apply_ptbr.py --apply
  python update_and_apply_ptbr.py --game-dir "C:\\Jogos\\LoveManiac" --merge --apply
"""

import argparse
import hashlib
import json
import shutil
import struct
import sys
from pathlib import Path

try:
    import zstandard as zstd
except ImportError:
    print("[ERRO] Biblioteca 'zstandard' não encontrada. Instale com: pip install zstandard")
    sys.exit(1)

REPO_GAME_DIR = Path(__file__).resolve().parent.parent
REPO_LANG_DIR = REPO_GAME_DIR / "lang"
DEFAULT_INSTALL_DIR = Path(r"C:\Jogos\LoveManiac")

SMAZ_CB = [
    " ", "the", "e", "t", "a", "of", "o", "and", "i", "n", "s", "e ", "r", " th",
    " t", "in", "he", "th", "h", "he ", "to", "\r\n", "l", "s ", "d", " a", "an",
    "er", "c", " o", "d ", "on", " of", "re", "of ", "t ", ", ", "is", "u", "at",
    "   ", "n ", "or", "which", "f", "m", "as", "it", "that", "\n", "was", "en",
    "  ", " w", "es", " an", " i", "\r", "f ", "g", "p", "nd", " s", "nd ", "ed ",
    "w", "ed", "http://", "for", "te", "ing", "y ", "The", " c", "ti", "r ", "his",
    "st", " in", "ar", "nt", ",", " to", "y", "ng", " h", "with", "le", "al", "to ",
    "b", "ou", "be", "were", " b", "se", "o ", "ent", "ha", "ng ", "their", "\"",
    "hi", "from", " f", "in ", "de", "ion", "me", "v", ".", "ve", "all", "re ",
    "ri", "ro", "is ", "co", "f t", "are", "ea", ". ", "her", " m", "er ", " p",
    "es ", "by", "they", "di", "ra", "ic", "not", "s, ", "d t", "at ", "ce", "la",
    "h ", "ne", "as ", "tio", "on ", "n t", "io", "we", " a ", "om", ", a", "s o",
    "ur", "li", "ll", "ch", "had", "this", "e t", "g ", "e\r\n", " wh", "ere",
    " co", "e o", "a ", "us", " d", "ss", "\n\r\n", "\r\n\r", "=\"", " be", " e",
    "s a", "ma", "one", "t t", "or ", "but", "el", "so", "l ", "e s", "s,", "no",
    "ter", " wa", "iv", "ho", "e a", " r", "hat", "s t", "ns", "ch ", "wh", "tr",
    "ut", "/", "have", "ly ", "ta", " ha", " on", "tha", "-", " l", "ati", "en ",
    "pe", " re", "there", "ass", "si", " fo", "wa", "ec", "our", "who", "its", "z",
    "fo", "rs", ">", "ot", "un", "<", "im", "th ", "nc", "ate", "><", "ver", "ad",
    " we", "ly", "ee", " n", "id", " cl", "ac", "il", "</", "rt", " wi", "div",
    "e, ", " it", "whi", " ma", "ge", "x", "e c", "men", ".com",
]


def smaz_decompress(buf: bytes) -> str:
    out = bytearray()
    i = 0
    n = len(buf)
    while i < n:
        c = buf[i]
        if c == 254:
            if i + 1 < n:
                out.append(buf[i + 1])
            i += 2
        elif c == 255:
            ln = buf[i + 1] + 1
            out.extend(buf[i + 2 : i + 2 + ln])
            i += 2 + ln
        else:
            out.extend(SMAZ_CB[c].encode("utf-8"))
            i += 1
    return out.decode("utf-8", "replace").rstrip("\x00")


def decompress_rscc(data: bytes) -> tuple[bytes, bool, int, int]:
    if not data.startswith(b"RSCC"):
        return data, False, 0, 0
    mode, block_size, read_total = struct.unpack("<3I", data[4:16])
    num_blocks = (read_total + block_size - 1) // block_size
    pos = 16
    c_sizes = struct.unpack(f"<{num_blocks}I", data[pos : pos + num_blocks * 4])
    pos += num_blocks * 4
    out = bytearray(b"RSRC")
    dctx = zstd.ZstdDecompressor()
    rem = read_total
    for csize in c_sizes:
        usize = min(block_size, rem)
        out.extend(dctx.decompress(data[pos : pos + csize], max_output_size=usize))
        pos += csize
        rem -= usize
    return bytes(out), True, mode, block_size


def compress_rscc(rsrc_data: bytes, mode: int = 2, block_size: int = 4096) -> bytes:
    assert rsrc_data.startswith(b"RSRC")
    payload = rsrc_data[4:]
    read_total = len(payload)
    num_blocks = (read_total + block_size - 1) // block_size
    cctx = zstd.ZstdCompressor()
    c_blocks = []
    for i in range(num_blocks):
        chunk = payload[i * block_size : (i + 1) * block_size]
        c_blocks.append(cctx.compress(chunk))
    out = bytearray(b"RSCC")
    out.extend(struct.pack("<3I", mode, block_size, read_total))
    for cb in c_blocks:
        out.extend(struct.pack("<I", len(cb)))
    for cb in c_blocks:
        out.extend(cb)
    return bytes(out)


def find_latest_pck(game_dir: Path) -> Path:
    pcks = sorted(game_dir.glob("LoveManiac*.pck"))
    if not pcks:
        raise FileNotFoundError(f"Nenhum arquivo LoveManiac*.pck encontrado em {game_dir}")
    return pcks[-1]


def read_pck_directory(pck_path: Path) -> tuple[int, int, list[dict]]:
    with pck_path.open("rb") as f:
        magic = f.read(4)
        if magic != b"GDPC":
            raise ValueError(f"Arquivo PCK inválido: {pck_path}")
        f.seek(24)
        file_base, dir_offset = struct.unpack("<2Q", f.read(16))
        f.seek(dir_offset)
        file_count = struct.unpack("<I", f.read(4))[0]
        entries = []
        for _ in range(file_count):
            path_len = struct.unpack("<I", f.read(4))[0]
            raw_path = f.read(path_len)
            clean_path = raw_path.decode("utf-8", "replace").rstrip("\x00")
            ofs, size = struct.unpack("<2Q", f.read(16))
            md5 = f.read(16)
            flags = struct.unpack("<I", f.read(4))[0]
            entries.append({
                "raw_path": raw_path,
                "path": clean_path,
                "ofs": ofs,
                "size": size,
                "md5": md5,
                "flags": flags,
            })
    return file_base, dir_offset, entries


def extract_opt_trans_entries(raw_bytes: bytes) -> dict[int, str]:
    rsrc, _, _, _ = decompress_rscc(raw_bytes)
    idx = rsrc.find(b"OptimizedTranslation\x00")
    idx2 = rsrc.find(b"OptimizedTranslation\x00", idx + 1)
    pos = idx2 + len(b"OptimizedTranslation\x00")
    prop_count = struct.unpack("<I", rsrc[pos : pos + 4])[0]
    pos += 4
    int_arrays = []
    byte_arrays = []
    for _ in range(prop_count):
        _, vtype = struct.unpack("<2I", rsrc[pos : pos + 8])
        pos += 8
        if vtype == 32:
            count = struct.unpack("<I", rsrc[pos : pos + 4])[0]
            arr = struct.unpack(f"<{count}i", rsrc[pos + 4 : pos + 4 + count * 4])
            int_arrays.append(arr)
            pos += 4 + count * 4
        elif vtype == 31:
            count = struct.unpack("<I", rsrc[pos : pos + 4])[0]
            byte_arrays.append(rsrc[pos + 4 : pos + 4 + count])
            pos += 4 + count + ((4 - (count % 4)) % 4)
        elif vtype in (4, 5):
            slen = struct.unpack("<I", rsrc[pos : pos + 4])[0]
            pos += 4 + slen
        elif vtype == 1:
            pass
    ht, bt = int_arrays[0], int_arrays[1]
    strs = byte_arrays[0]
    result = {}
    for h_val in ht:
        if h_val == -1:
            continue
        b_idx = h_val
        size = bt[b_idx]
        for j in range(size):
            key_h, str_ofs, comp_size, uncomp_size = bt[b_idx + 2 + j * 4 : b_idx + 2 + j * 4 + 4]
            raw = strs[str_ofs : str_ofs + comp_size]
            if comp_size == uncomp_size:
                text = raw.decode("utf-8", "replace").rstrip("\x00")
            else:
                text = smaz_decompress(raw)
            result[key_h] = text
    return result


def build_patched_opt_trans(raw_bytes: bytes, hash_to_pt: dict[int, str]) -> bytes:
    rsrc, is_rscc, mode, block_size = decompress_rscc(raw_bytes)
    idx = rsrc.find(b"OptimizedTranslation\x00")
    idx2 = rsrc.find(b"OptimizedTranslation\x00", idx + 1)
    pos = idx2 + len(b"OptimizedTranslation\x00")
    prefix = rsrc[:pos]
    prop_count = struct.unpack("<I", rsrc[pos : pos + 4])[0]
    pos += 4

    prop_list = []
    int_indices = []
    byte_index = -1

    for i in range(prop_count):
        prop_idx, vtype = struct.unpack("<2I", rsrc[pos : pos + 8])
        pos += 8
        if vtype == 32:
            count = struct.unpack("<I", rsrc[pos : pos + 4])[0]
            arr = list(struct.unpack(f"<{count}i", rsrc[pos + 4 : pos + 4 + count * 4]))
            pos += 4 + count * 4
            int_indices.append(i)
            prop_list.append([prop_idx, vtype, arr])
        elif vtype == 31:
            count = struct.unpack("<I", rsrc[pos : pos + 4])[0]
            b_arr = rsrc[pos + 4 : pos + 4 + count]
            pos += 4 + count + ((4 - (count % 4)) % 4)
            byte_index = i
            prop_list.append([prop_idx, vtype, b_arr])
        elif vtype in (4, 5):
            slen = struct.unpack("<I", rsrc[pos : pos + 4])[0]
            raw_s = rsrc[pos : pos + 4 + slen]
            pos += 4 + slen
            prop_list.append([prop_idx, vtype, raw_s])
        elif vtype == 1:
            prop_list.append([prop_idx, vtype, b""])
        else:
            raise ValueError(f"Tipo de propriedade inesperado: {vtype}")

    suffix = rsrc[pos:]
    assert suffix == b"RSRC", f"Sufixo RSRC inválido: {suffix!r}"
    ht = prop_list[int_indices[0]][2]
    bt = prop_list[int_indices[1]][2]
    old_strs = prop_list[byte_index][2]

    new_strs = bytearray()
    for h_val in ht:
        if h_val == -1:
            continue
        b_idx = h_val
        size = bt[b_idx]
        for j in range(size):
            base = b_idx + 2 + j * 4
            key_h = bt[base]
            old_ofs = bt[base + 1]
            old_comp = bt[base + 2]
            if key_h in hash_to_pt:
                pt_bytes = hash_to_pt[key_h].encode("utf-8") + b"\x00"
                new_ofs = len(new_strs)
                new_strs.extend(pt_bytes)
                bt[base + 1] = new_ofs
                bt[base + 2] = len(pt_bytes)
                bt[base + 3] = len(pt_bytes)
            else:
                raw_slice = old_strs[old_ofs : old_ofs + old_comp]
                new_ofs = len(new_strs)
                new_strs.extend(raw_slice)
                bt[base + 1] = new_ofs

    prop_list[byte_index][2] = bytes(new_strs)

    out_rsrc = bytearray(prefix)
    out_rsrc.extend(struct.pack("<I", prop_count))
    for prop_idx, vtype, val in prop_list:
        out_rsrc.extend(struct.pack("<2I", prop_idx, vtype))
        if vtype == 32:
            out_rsrc.extend(struct.pack("<I", len(val)))
            out_rsrc.extend(struct.pack(f"<{len(val)}i", *val))
        elif vtype == 31:
            out_rsrc.extend(struct.pack("<I", len(val)))
            out_rsrc.extend(val)
            pad = (4 - (len(val) % 4)) % 4
            if pad:
                out_rsrc.extend(b"\x00" * pad)
        else:
            out_rsrc.extend(val)
    out_rsrc.extend(suffix)

    if is_rscc:
        return compress_rscc(bytes(out_rsrc), mode, block_size)
    return bytes(out_rsrc)


def check_and_merge(game_dir: Path, do_merge: bool = False) -> int:
    pck_path = find_latest_pck(game_dir)
    orig_pck = pck_path.with_name(pck_path.name + ".orig")
    source_pck = orig_pck if orig_pck.exists() else pck_path

    file_base, _, entries = read_pck_directory(source_pck)
    en_entries = [e for e in entries if e["path"].endswith(".en.translation")]

    pt_path = REPO_LANG_DIR / "pt_br.json"
    pt_data = json.loads(pt_path.read_text(encoding="utf-8"))
    files_pt = pt_data.get("files", {})
    by_en = pt_data.get("by_en", {})

    total_strings = 0
    translated_strings = 0
    new_strings = []

    with source_pck.open("rb") as f:
        for e in en_entries:
            fp = e["path"]
            f.seek(file_base + e["ofs"])
            raw = f.read(e["size"])
            extracted = extract_opt_trans_entries(raw)
            fp_dict = files_pt.setdefault(fp, {})
            for key_h, en_text in extracted.items():
                total_strings += 1
                h_str = str(key_h)
                if h_str in fp_dict and not fp_dict[h_str].startswith("[TODO_PTBR]"):
                    translated_strings += 1
                elif en_text in by_en:
                    fp_dict[h_str] = by_en[en_text]
                    translated_strings += 1
                else:
                    new_strings.append((fp, h_str, en_text))
                    if do_merge:
                        fp_dict[h_str] = f"[TODO_PTBR] {en_text}"

    print(f"=== Status da Tradução PT-BR ({pck_path.name}) ===")
    print(f"Arquivos .translation (grupos) : {len(en_entries)}")
    print(f"Total de entradas no PCK       : {total_strings}")
    print(f"Total traduzidas (PT-BR)       : {translated_strings}")
    print(f"Novas entradas sem tradução    : {len(new_strings)}")

    if do_merge and new_strings:
        pt_data["files"] = files_pt
        pt_path.write_text(json.dumps(pt_data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"[OK] {len(new_strings)} novas entradas mescladas em {pt_path}")

    return 0


def apply_translation(game_dir: Path) -> int:
    pck_path = find_latest_pck(game_dir)
    orig_pck = pck_path.with_name(pck_path.name + ".orig")

    if not orig_pck.exists():
        shutil.copy2(pck_path, orig_pck)
        print(f"[BACKUP] Backup original salvo em: {orig_pck}")
    else:
        shutil.copy2(orig_pck, pck_path)

    file_base, dir_offset, entries = read_pck_directory(pck_path)
    pt_data = json.loads((REPO_LANG_DIR / "pt_br.json").read_text(encoding="utf-8"))
    files_pt = pt_data.get("files", {})
    by_en = pt_data.get("by_en", {})

    # Mapeia cada grupo base (sem .en.translation) para seu dicionário {hash_int: pt_text}
    base_to_hash_pt = {}
    for en_fp, h_map in files_pt.items():
        base = en_fp.removesuffix(".en.translation")
        base_to_hash_pt[base] = {int(k): v for k, v in h_map.items()}

    patched_count = 0
    with pck_path.open("r+b") as f:
        write_cursor = dir_offset
        for e in entries:
            fp = e["path"]
            base = None
            if fp.endswith(".en.translation"):
                base = fp.removesuffix(".en.translation")
            elif fp.endswith(".es.translation"):
                base = fp.removesuffix(".es.translation")
            elif fp.endswith(".esp.translation"):
                base = fp.removesuffix(".esp.translation")

            if base is None or base not in base_to_hash_pt:
                continue

            f.seek(file_base + e["ofs"])
            raw_orig = f.read(e["size"])
            patched_bytes = build_patched_opt_trans(raw_orig, base_to_hash_pt[base])

            # Alinha write_cursor em 32 bytes relativo a file_base
            rel_ofs = write_cursor - file_base
            if rel_ofs % 32 != 0:
                pad = 32 - (rel_ofs % 32)
                write_cursor += pad
                rel_ofs += pad

            f.seek(write_cursor)
            f.write(patched_bytes)
            write_cursor += len(patched_bytes)

            e["ofs"] = rel_ofs
            e["size"] = len(patched_bytes)
            e["md5"] = hashlib.md5(patched_bytes).digest()
            patched_count += 1

        # Alinha início do novo diretório em 16 bytes
        if write_cursor % 16 != 0:
            pad = 16 - (write_cursor % 16)
            f.seek(write_cursor)
            f.write(b"\x00" * pad)
            write_cursor += pad

        new_dir_offset = write_cursor
        f.seek(new_dir_offset)
        f.write(struct.pack("<I", len(entries)))
        for e in entries:
            f.write(struct.pack("<I", len(e["raw_path"])))
            f.write(e["raw_path"])
            f.write(struct.pack("<2Q", e["ofs"], e["size"]))
            f.write(e["md5"])
            f.write(struct.pack("<I", e["flags"]))

        f.truncate()
        # Atualiza dir_offset no cabeçalho PCK v3 (byte 32)
        f.seek(32)
        f.write(struct.pack("<Q", new_dir_offset))

    print(f"[APLICADO] {patched_count} recursos .translation (.en/.es/.esp) atualizados em: {pck_path}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Gerenciador de tradução PT-BR do LoveManiac")
    parser.add_argument("--game-dir", type=Path, default=DEFAULT_INSTALL_DIR, help="Pasta de instalação do jogo")
    parser.add_argument("--check", action="store_true", help="Verifica o status da tradução")
    parser.add_argument("--merge", action="store_true", help="Mescla novas entradas de uma atualização")
    parser.add_argument("--apply", action="store_true", help="Aplica a tradução PT-BR no arquivo .pck")

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
