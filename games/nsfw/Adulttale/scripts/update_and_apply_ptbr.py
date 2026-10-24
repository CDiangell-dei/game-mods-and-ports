#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Utilitário de Atualização e Aplicação da Tradução PT-BR — Adulttale
Página Oficial: https://adulttale.itch.io/adulttale

Funções:
1. --check: Compara o eng.json de uma nova versão do jogo com o pt.json do repositório,
   listando chaves novas que precisam de tradução e chaves removidas.
2. --merge: Mescla automaticamente nossa tradução PT-BR com o novo eng.json, mantendo
   100% do que já foi traduzido e inserindo novas chaves (marcadas ou em inglês) na ordem exata.
3. --apply: Aplica a tradução PT-BR (pt.json -> pt.json e esp.json) na pasta do jogo instalado
   e configura o idioma padrão no settings.ini (%LOCALAPPDATA%/Adulttale).
"""

import os
import sys
import json
import shutil
import argparse

REPO_ADULTTALE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
REPO_LANG_DIR = os.path.join(REPO_ADULTTALE_DIR, 'lang')
REPO_PT_JSON = os.path.join(REPO_LANG_DIR, 'pt.json')
DEFAULT_GAME_DIR = r'C:\Jogos\Adulttale'
LOCALAPPDATA_SAVE_DIR = os.path.expandvars(r'%LOCALAPPDATA%\Adulttale')


def load_json(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_json(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def check_diff(game_dir):
    target_eng_path = os.path.join(game_dir, 'lang', 'eng.json')
    if not os.path.exists(target_eng_path):
        print(f"[!] Arquivo não encontrado: {target_eng_path}")
        return None, None

    eng_data = load_json(target_eng_path)
    pt_data = load_json(REPO_PT_JSON)

    eng_keys = set(eng_data.keys())
    pt_keys = set(pt_data.keys())

    new_keys = [k for k in eng_data.keys() if k not in pt_keys]
    removed_keys = [k for k in pt_data.keys() if k not in eng_keys]
    common_keys = [k for k in eng_data.keys() if k in pt_keys]

    print("=== Relatório de Comparação de Versão (Adulttale PT-BR) ===")
    print(f"Total de chaves no jogo alvo (eng.json): {len(eng_keys)}")
    print(f"Total de chaves traduzidas (pt.json):    {len(pt_keys)}")
    print(f"Chaves reaproveitadas (já traduzidas):   {len(common_keys)}")
    print(f"Chaves novas (adicionadas na update):    {len(new_keys)}")
    print(f"Chaves obsoletas (removidas na update):  {len(removed_keys)}")

    if new_keys:
        print("\n[+] Novas chaves detectadas:")
        for k in new_keys[:30]:
            print(f"  - {k}: {repr(eng_data[k])[:80]}")
        if len(new_keys) > 30:
            print(f"  ... e mais {len(new_keys) - 30} chaves.")
    else:
        print("\n[✓] Nenhuma chave nova! A tradução está 100% compatível com esta versão.")

    return eng_data, pt_data


def merge_translation(game_dir):
    eng_data, pt_data = check_diff(game_dir)
    if eng_data is None:
        return

    merged = {}
    new_count = 0
    for k, eng_val in eng_data.items():
        if k in pt_data:
            merged[k] = pt_data[k]
        else:
            merged[k] = eng_val
            new_count += 1

    # Atualiza o pt.json e esp.json do repositório
    save_json(REPO_PT_JSON, merged)
    save_json(os.path.join(REPO_LANG_DIR, 'esp.json'), merged)
    # Atualiza também o eng.json de referência no repositório
    shutil.copy2(os.path.join(game_dir, 'lang', 'eng.json'), os.path.join(REPO_LANG_DIR, 'eng.json'))

    print(f"\n[✓] Mesclagem concluída! {len(merged)} chaves salvas em {REPO_PT_JSON} ({new_count} novas chaves adicionadas).")


def apply_translation(game_dir):
    target_lang_dir = os.path.join(game_dir, 'lang')
    if not os.path.exists(target_lang_dir):
        print(f"[!] Pasta lang não encontrada em: {target_lang_dir}")
        return

    # Faz backup do esp.json original caso ainda não exista esp_original.json
    target_esp = os.path.join(target_lang_dir, 'esp.json')
    target_esp_orig = os.path.join(target_lang_dir, 'esp_original.json')
    if os.path.exists(target_esp) and not os.path.exists(target_esp_orig):
        pt_check = load_json(target_esp)
        if pt_check.get("lang_main_menu_option_lang") != "Português":
            shutil.copy2(target_esp, target_esp_orig)
            print(f"[+] Backup do espanhol original criado em: {target_esp_orig}")

    # Copia pt.json e sobrescreve esp.json (usado pelo seletor nativo do jogo para exibir Português)
    shutil.copy2(REPO_PT_JSON, os.path.join(target_lang_dir, 'pt.json'))
    shutil.copy2(REPO_PT_JSON, target_esp)
    print(f"[✓] Tradução PT-BR aplicada em: {target_lang_dir}")

    # Garante que settings.ini use language="esp" (slot onde o Português fica ativo nativamente)
    settings_path = os.path.join(LOCALAPPDATA_SAVE_DIR, 'settings.ini')
    if os.path.exists(settings_path):
        with open(settings_path, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'language=' in content:
            import re
            content = re.sub(r'language="[^"]*"', 'language="esp"', content)
            with open(settings_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"[✓] Idioma configurado como Português (slot 'esp') em: {settings_path}")


def main():
    parser = argparse.ArgumentParser(description="Gerenciador de Tradução e Atualização PT-BR do Adulttale")
    parser.add_argument('--game-dir', default=DEFAULT_GAME_DIR, help=f"Caminho da pasta do jogo (padrão: {DEFAULT_GAME_DIR})")
    parser.add_argument('--check', action='store_true', help="Verifica diferenças entre a versão instalada e a tradução PT-BR")
    parser.add_argument('--merge', action='store_true', help="Mescla chaves novas do jogo instalado no pt.json mantendo as traduções existentes")
    parser.add_argument('--apply', action='store_true', help="Instala a tradução PT-BR na pasta do jogo")
    args = parser.parse_args()

    if args.check:
        check_diff(args.game_dir)
    elif args.merge:
        merge_translation(args.game_dir)
        apply_translation(args.game_dir)
    elif args.apply:
        apply_translation(args.game_dir)
    else:
        check_diff(args.game_dir)
        apply_translation(args.game_dir)


if __name__ == '__main__':
    main()
