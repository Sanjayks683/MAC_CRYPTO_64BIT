import os, re
def remove_comments(text):
    # Remove block comments
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    # Remove line comments
    text = re.sub(r'//.*', '', text)
    # Remove empty lines
    return "\n".join([s for s in text.splitlines() if s.strip()])

for root, dirs, files in os.walk('.'):
    if '.git' in root or '.gemini' in root:
        continue
    for file in files:
        if file.endswith('.sv'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            clean_content = remove_comments(content)
            with open(filepath, 'w') as f:
                f.write(clean_content + '\n')
