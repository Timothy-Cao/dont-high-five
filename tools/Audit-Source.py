"""Check static Godot resource paths and authoring syntax without installing packages."""
import ast
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RESOURCE = re.compile(r'["\'](res://[^"\'\n]+\.(?:gd|glb|gdshader|tscn|ttf|wav|ogg|mp3|png))["\']')
errors = []
references = 0
for directory in ("scripts", "tests", "scenes"):
    for source in (ROOT / directory).rglob("*"):
        if source.suffix not in (".gd", ".tscn"):
            continue
        for match in RESOURCE.finditer(source.read_text(encoding="utf-8")):
            relative = match[1].removeprefix("res://")
            if relative.startswith(".local/") or "%" in relative:
                continue  # Generated outputs / formatted paths are covered by engine tests.
            references += 1
            if not (ROOT / relative).is_file():
                errors.append(f"{source.relative_to(ROOT)}: missing {relative}")

for directory in ("art", "tools"):
    for source in (ROOT / directory).glob("*.py"):
        try:
            ast.parse(source.read_text(encoding="utf-8"), filename=str(source))
        except SyntaxError as error:
            errors.append(str(error))

uids = {}
for directory in ("scripts", "tests"):
    for source in (ROOT / directory).rglob("*.uid"):
        uid = source.read_text(encoding="utf-8").strip()
        if uid in uids:
            errors.append(f"Duplicate UID: {source} and {uids[uid]}")
        uids[uid] = source

if errors:
    raise SystemExit("\n".join(errors))
print(f"Source audit passed: {references} static resource references, unique script UIDs, authoring syntax.")
