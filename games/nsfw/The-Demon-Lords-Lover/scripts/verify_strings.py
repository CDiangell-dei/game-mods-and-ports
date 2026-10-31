import json, re

SRC_PATH = 'C:/Jogos/The Demon Lord\'s Lover/the-demon-lords-lover-0.18.54-win_Data/StreamingAssets/Localization/source/strings.json'
PT_PATH = 'C:/Users/cield/.gemini/antigravity/brain/557bbb2c-03a4-422a-b9c5-99d6f059681b/scratch/strings_pt.json'

with open(SRC_PATH, 'r', encoding='utf-8') as f:
    src = json.load(f)

with open(PT_PATH, 'r', encoding='utf-8') as f:
    pt = json.load(f)

# TranslationCompatibility regex for variables:
var_regex = re.compile(r'\{([\w.-]+)(?:\|[^}]*)?\}')

def get_vars(s):
    return set(var_regex.findall(s))

mismatches = []
def check_tree(s_node, pt_node, path=""):
    if isinstance(s_node, str):
        s_vars = get_vars(s_node)
        pt_vars = get_vars(pt_node)
        if s_vars != pt_vars:
            mismatches.append((path, s_node, pt_node, s_vars, pt_vars))
    elif isinstance(s_node, dict):
        for k in s_node:
            check_tree(s_node[k], pt_node.get(k, ""), f"{path}.{k}")
    elif isinstance(s_node, list):
        for idx in range(len(s_node)):
            check_tree(s_node[idx], pt_node[idx], f"{path}[{idx}]")

check_tree(src, pt)
print(f"Total variable mismatches: {len(mismatches)}")
if mismatches:
    for m in mismatches[:10]:
        print(f"Path: {m[0]}")
        print(f"  SRC: {m[1]}")
        print(f"  PT:  {m[2]}")
        print(f"  SRC vars: {m[3]}, PT vars: {m[4]}")
