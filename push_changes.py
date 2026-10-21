import os
import subprocess
import urllib.parse

repo_dir = r'C:\Jogos\game-mods-and-ports'

# 1. Git add
print("1. git add -A...")
subprocess.run(['git', 'add', '-A'], cwd=repo_dir, check=True)

# 2. Git commit
print("2. git commit...")
commit_msg = "fix(mge): redesign title menu layout, complete translation review, fix android standalone apk"
res = subprocess.run(['git', 'commit', '-m', commit_msg], cwd=repo_dir, capture_output=True, text=True)
print("Commit output:\n", res.stdout)

# 3. Read token from ~/.git-credentials
cred_file = os.path.expanduser('~/.git-credentials')
token = None
if os.path.exists(cred_file):
    with open(cred_file, 'r', encoding='utf-8') as f:
        for line in f:
            if 'github.com' in line:
                # format: https://username:token@github.com
                parsed = urllib.parse.urlparse(line.strip())
                token = parsed.password
                username = parsed.username
                break

if not token:
    print("Could not find token in .git-credentials!")
    exit(1)

# 4. Push with token
authed_url = f"https://{username}:{token}@github.com/CDiangell-dei/game-mods-and-ports.git"
clean_url = "https://github.com/CDiangell-dei/game-mods-and-ports.git"

print("3. Pushing to origin main...")
push_res = subprocess.run(['git', 'push', authed_url, 'main'], cwd=repo_dir, capture_output=True, text=True)
print("Push output:\n", push_res.stdout)
if push_res.stderr:
    # Do not leak token in logs
    safe_err = push_res.stderr.replace(token, '***')
    print("Push stderr:\n", safe_err)

if push_res.returncode == 0:
    print("SUCCESS: Pushed to GitHub repository!")
else:
    print("Push failed with code:", push_res.returncode)
