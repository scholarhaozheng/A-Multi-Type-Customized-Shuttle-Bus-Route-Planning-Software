"""Check MATLAB entry names, local Markdown targets/anchors and the data checksum."""
import argparse
import hashlib
import html
import json
import re
from functools import lru_cache
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]


def require(condition, message):
    if not condition:
        raise ValueError(message)


def exact_local_target(document, target):
    """Resolve a repository link while checking each component's literal case."""
    current = ROOT if target.startswith("/") else document.parent
    for part in target.split("/"):
        if part in ("", "."):
            continue
        if part == "..":
            current = current.parent
            require(current == ROOT or ROOT in current.parents,
                    f"Link leaves the repository in {document}: {target}")
            continue
        require(current.is_dir(), f"Broken link in {document}: {target}")
        names = {entry.name for entry in current.iterdir()}
        if part not in names:
            alternatives = sorted(name for name in names if name.casefold() == part.casefold())
            detail = f" (case differs from {alternatives[0]!r})" if alternatives else ""
            raise ValueError(f"Broken link in {document}: {target}{detail}")
        current = current / part
    require(current.exists(), f"Broken link in {document}: {target}")
    return current


def without_fenced_code(source):
    """Exclude code examples and HTML comments from documentation checks."""
    source = re.sub(r"<!--.*?-->", "", source, flags=re.S)
    lines = []
    fence = None
    for line in source.splitlines():
        marker = re.match(r"^ {0,3}(`{3,}|~{3,})(.*)$", line)
        if fence is not None:
            if marker and marker[1][0] == fence[0] and len(marker[1]) >= fence[1] and not marker[2].strip():
                fence = None
            continue
        if marker:
            fence = (marker[1][0], len(marker[1]))
            continue
        lines.append(line)
    return "\n".join(lines)


def heading_slug(heading):
    """GitHub-style slugs for text, inline code and ordinary Markdown headings."""
    heading = re.sub(r"!?\[([^]]*)\]\([^)]*\)", r"\1", heading)
    heading = re.sub(r"<[^>]+>", "", heading)
    heading = html.unescape(heading).strip().lower().replace("`", "")
    heading = re.sub(r"[^\w\- ]", "", heading)
    return heading.replace(" ", "-")


@lru_cache(maxsize=None)
def markdown_anchors(path):
    source = without_fenced_code(path.read_text(encoding="utf-8-sig"))
    anchors = set(re.findall(r"\b(?:id|name)\s*=\s*['\"]([^'\"]+)['\"]", source))
    generated = set()
    lines = source.splitlines()
    for index, line in enumerate(lines):
        match = re.match(r"^ {0,3}#{1,6}\s+(.+?)(?:\s+#+\s*)?$", line)
        heading = match[1] if match else None
        if heading is None and index + 1 < len(lines) and line.strip() and not line.startswith("    "):
            if re.fullmatch(r" {0,3}(?:=+|-+)\s*", lines[index + 1]):
                heading = line.strip()
        if heading is None:
            continue
        base = heading_slug(heading)
        slug = base
        suffix = 0
        while slug in generated:
            suffix += 1
            slug = f"{base}-{suffix}"
        generated.add(slug)
        anchors.add(slug)
    return anchors


def check_document_link(document, target):
    parsed = urlsplit(target)
    if parsed.scheme or parsed.netloc:
        return False, False
    filename, fragment = unquote(parsed.path), unquote(parsed.fragment)
    destination = exact_local_target(document, filename) if filename else document
    if fragment:
        if destination.is_dir():
            destination = exact_local_target(destination / "index.md", "README.md")
        require(destination.suffix.lower() == ".md",
                f"Cannot verify a Markdown fragment in {document}: {target}")
        require(fragment in markdown_anchors(destination),
                f"Broken heading link in {document}: {target}")
    return True, bool(fragment)


def inspect():
    markdown_anchors.cache_clear()
    manifest = json.loads((ROOT / "data" / "data_inventory.json").read_text(encoding="utf-8"))
    source = manifest["source"]
    snapshot = ROOT / source["file"]
    require(hashlib.sha256(snapshot.read_bytes()).hexdigest() == source["sha256"], "MAT checksum mismatch")
    checked = []
    for path in sorted(ROOT.glob("*.m")):
        source = path.read_text(encoding="utf-8-sig")
        match = re.search(r"^\s*function\s+(?:\[[^]]*\]\s*=\s*|\w+\s*=\s*)?(\w+)\s*\(", source, re.M)
        require(match and match.group(1) == path.stem, f"Entry name mismatch: {path.name}")
        require(not re.search(r"^\s*pause\s*\(", source, re.M), f"Blocking pause: {path.name}")
        checked.append(path.name)
    links = 0
    anchors = 0
    for path in ROOT.rglob("*.md"):
        if ".git" in path.parts:
            continue
        source = without_fenced_code(path.read_text(encoding="utf-8-sig"))
        for match in re.finditer(r"\]\(\s*(?:<([^>]+)>|([^\s)]+))(?:\s+['\"][^)]*['\"])?\s*\)", source):
            target = match[1] or match[2]
            local, anchored = check_document_link(path, target)
            links += local
            anchors += anchored
    return {"mat_checksum_valid": True, "root_function_names_checked": len(checked),
            "local_links_checked": links, "local_anchors_checked": anchors}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = inspect()
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
