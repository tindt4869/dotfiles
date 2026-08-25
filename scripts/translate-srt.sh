#!/usr/bin/env bash
set -euo pipefail

MODEL="$HOME/.local/share/llama.cpp/gemma-3-4b-it-Q4_K_M.gguf"
LANG_CODE="${TRANSLATE_LANG:-vie}"
LANG_NAME="${TRANSLATE_LANG_NAME:-Vietnamese}"
SRC_CODE="${TRANSLATE_SRC:-en}"
SERVER="${LLAMA_SERVER:-llama-server}"
PORT="${TRANSLATE_PORT:-8137}"
CTX="${TRANSLATE_CTX:-8192}"
CHUNK="${TRANSLATE_CHUNK:-30}"
JOBS="${TRANSLATE_JOBS:-4}"
KEEP_SERVER=0
FIXES="${TRANSLATE_FIXES:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/srt-fixes.tsv}"
DOMAIN="${TRANSLATE_DOMAIN:-}"
NORMALIZE_ONLY=0
QUICK=0

src_name_for() {
    case "$1" in
        en) echo "English" ;;
        ja) echo "Japanese" ;;
        vi|vie) echo "Vietnamese" ;;
        ko) echo "Korean" ;;
        zh) echo "Chinese" ;;
        fr) echo "French" ;;
        de) echo "German" ;;
        es) echo "Spanish" ;;
        ru) echo "Russian" ;;
        *) echo "$1" ;;
    esac
}

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <file.srt> [more.srt...]

Translate subtitle files to Vietnamese using the local Gemma 3 4B model.
Source language defaults to English; use -s for others (e.g. -s ja).
Timestamps and subtitle numbering are preserved exactly; only text is replaced.
Output is written to <name>.$LANG_CODE.srt next to each input (an existing
.<lang> suffix on the input name is replaced, so video.ja.srt -> video.vie.srt).

Options:
  -k            keep llama-server running after finishing (don't kill it)
  -n            normalize only: apply the fix dictionary, write <name>.norm.srt,
                print changed lines, and exit (llama-server is never started)
  -F FILE       fix dictionary path (default: srt-fixes.tsv next to this script)
  -d TEXT       domain hint appended to the translator system prompt
  -q            quick mode: skip the second review pass
  -s LANG       source language code or name (default: en)
  -j N          parallel translation workers (default: 4)
  -p PORT       server port (default: 8137)
  -c N          context size (default: 8192)
  -h            show this help

Environment overrides: LLAMA_SERVER, TRANSLATE_SRC, TRANSLATE_PORT, TRANSLATE_CTX, TRANSLATE_CHUNK, TRANSLATE_JOBS, TRANSLATE_FIXES, TRANSLATE_DOMAIN
EOF
}

while getopts ":ks:p:c:j:nqd:F:h" opt; do
    case "$opt" in
        k) KEEP_SERVER=1 ;;
        s) SRC_CODE="$OPTARG" ;;
        p) PORT="$OPTARG" ;;
        c) CTX="$OPTARG" ;;
        j) JOBS="$OPTARG" ;;
        n) NORMALIZE_ONLY=1 ;;
        q) QUICK=1 ;;
        d) DOMAIN="$OPTARG" ;;
        F) FIXES="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

SRC_NAME="$(src_name_for "$SRC_CODE")"

[[ $# -eq 0 ]] && { usage; exit 1; }
for f in "$@"; do
    [[ -f "$f" ]] || { echo "error: no such file: $f" >&2; exit 1; }
done

if [[ "$NORMALIZE_ONLY" -eq 0 ]]; then
    if [[ ! -x "$(command -v "$SERVER")" ]]; then
        echo "error: $SERVER not found in PATH" >&2
        exit 1
    fi
    if [[ ! -f "$MODEL" ]]; then
        echo "error: model not found at $MODEL" >&2
        exit 1
    fi

    # find a free port if the requested one is in use
    while curl -s "http://127.0.0.1:$PORT/health" >/dev/null 2>&1; do
        echo "port $PORT busy, trying next..."
        PORT=$((PORT + 1))
    done

    LOGFILE="$(mktemp /tmp/llama-server.XXXXXX.log)"
    SERVER_PID=""
    cleanup() {
        if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
            kill "$SERVER_PID" 2>/dev/null || true
            wait "$SERVER_PID" 2>/dev/null || true
        fi
        rm -f "$LOGFILE"
    }
    trap cleanup EXIT

    # -c is per-slot: llama-server splits total ctx across -np slots,
    # so scale it up to keep each worker's usable context at $CTX
    echo "Starting llama-server (port $PORT, ctx $CTX x $JOBS workers)..."
    "$SERVER" -m "$MODEL" -ngl 99 -c "$((CTX * JOBS))" -np "$JOBS" --host 127.0.0.1 --port "$PORT" \
        -t 12 --log-file "$LOGFILE" &
    SERVER_PID=$!

    # wait for server readiness
    ready=0
    for _ in $(seq 1 120); do
        if curl -s "http://127.0.0.1:$PORT/health" 2>/dev/null | grep -q ok; then
            ready=1
            break
        fi
        kill -0 "$SERVER_PID" 2>/dev/null || break
        sleep 1
    done
    if [[ "$ready" -eq 0 ]]; then
        echo "error: llama-server failed to start" >&2
        tail -20 "$LOGFILE" >&2
        exit 1
    fi
    echo "llama-server ready."
fi

FAILED=0

out_base() {
    local b="${1%.srt}"
    if [[ "$b" =~ \.(en|ja|vi|ko|zh|fr|de|es|ru|it|pt|th|ar|hi|id|vie|jpn|kor|zho|chi|fra|deu|spa|rus)$ ]]; then
        b="${b%.*}"
    fi
    echo "$b"
}

for srt in "$@"; do
    # video.ja.srt -> video.vie.srt ; plain name.srt -> name.vie.srt
    # (-n mode writes video.norm.srt instead)
    base="$(out_base "$srt")"
    if [[ "$NORMALIZE_ONLY" -eq 1 ]]; then
        out="$base.norm.srt"
    else
        out="$base.$LANG_CODE.srt"
    fi
    echo "==> $srt -> $out"
    if python3 - "$srt" "$out" "$PORT" "$CHUNK" "$LANG_NAME" "$LANG_CODE" "$SRC_NAME" "$JOBS" "$FIXES" "$DOMAIN" "$NORMALIZE_ONLY" "$QUICK" <<'PYEOF'
import json
import re
import sys
import threading
import urllib.request
from concurrent.futures import ThreadPoolExecutor

SRT, OUT, PORT, CHUNK, LANG_NAME, LANG_CODE, SRC_NAME, JOBS, FIXES, DOMAIN, NORM, QUICK = sys.argv[1:13]
CHUNK = int(CHUNK)
JOBS = int(JOBS)
NORM = NORM == "1"
QUICK = QUICK == "1"
CONTEXT_LINES = 6
URL = f"http://127.0.0.1:{PORT}/v1/chat/completions"

def parse_srt(path):
    blocks = []
    cur = None
    with open(path, encoding="utf-8") as fh:
        for raw in fh:
            line = raw.rstrip("\n")
            if not line.strip():
                if cur:
                    blocks.append(cur)
                    cur = None
                continue
            if cur is None:
                if line.strip().isdigit():
                    cur = {"time": None, "text": []}
            elif cur["time"] is None:
                cur["time"] = line
            else:
                cur["text"].append(line)
    if cur:
        blocks.append(cur)
    return blocks

def load_fixes(path):
    rules = []
    try:
        fh = open(path, encoding="utf-8")
    except OSError:
        print(f"note: no fix dictionary at {path}; normalization skipped", flush=True)
        return rules
    with fh:
        for ln, raw in enumerate(fh, 1):
            line = raw.rstrip("\n")
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) < 2:
                print(f"WARN: {path}:{ln}: expected pattern<TAB>replacement, skipped", flush=True)
                continue
            pat, rep = parts[0], parts[1]
            is_re = pat.startswith("re:")
            rules.append((pat[3:] if is_re else pat, rep, is_re))
    return rules

fix_hits = {}

def apply_fixes(lines, rules):
    out = []
    changed = False
    for text in lines:
        t = text
        for i, (pat, rep, is_re) in enumerate(rules):
            new = re.sub(pat, rep, t) if is_re else t.replace(pat, rep)
            if new != t:
                fix_hits[i] = fix_hits.get(i, 0) + 1
                t = new
        if t != text:
            changed = True
        out.append(t)
    return out, changed

def print_fix_summary(rules):
    if not fix_hits:
        print("    no fix rules matched", flush=True)
        return
    for i, n in sorted(fix_hits.items()):
        kind = "regex" if rules[i][2] else "literal"
        print(f"    fix #{i + 1} ({kind}) '{rules[i][0]}' -> '{rules[i][1]}': {n} hit(s)", flush=True)

def chat(system, user_content, max_tokens=2048):
    body = json.dumps({
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user_content},
        ],
        "temperature": 0.2,
        "max_tokens": max_tokens,
        "stream": False,
    }).encode()
    req = urllib.request.Request(URL, data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=600) as resp:
        data = json.loads(resp.read())
    return data["choices"][0]["message"]["content"].strip()

def parse_result(text, n):
    trans = {}
    t = text.strip()
    if t.startswith("```"):
        t = t.split("\n", 1)[-1]
        t = t.rsplit("```", 1)[0]
    try:
        obj = json.loads(t)
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, list):
                    for j, item in enumerate(v):
                        trans[j] = str(item)
                else:
                    try:
                        trans[int(k)] = str(v)
                    except ValueError:
                        pass
        elif isinstance(obj, list):
            for j, item in enumerate(obj):
                trans[j] = str(item)
    except json.JSONDecodeError:
        pass
    if len(trans) < n:
        for m in re.finditer(r'"(\d+)"\s*:\s*"((?:[^"\\]|\\.)*)"', t):
            trans[int(m.group(1))] = m.group(2)
    if len(trans) < n:
        for raw in text.splitlines():
            line = raw.strip().lstrip("-* ").strip()
            parts = line.split("|", 1)
            if len(parts) == 2:
                try:
                    trans[int(parts[0])] = parts[1].strip()
                except ValueError:
                    pass
    return trans

blocks = parse_srt(SRT)
total = len(blocks)
print(f"    {total} subtitle blocks")

rules = load_fixes(FIXES)
changed_blocks = []
for idx, b in enumerate(blocks):
    fixed, ch = apply_fixes(b["text"], rules)
    if ch:
        changed_blocks.append((idx, b["text"], fixed))
        b["text"] = fixed
print_fix_summary(rules)

if NORM:
    with open(OUT, "w", encoding="utf-8") as outfh:
        for i, b in enumerate(blocks):
            if i > 0:
                outfh.write("\n")
            outfh.write(f"{i + 1}\n{b['time']}\n")
            for line in b["text"]:
                outfh.write(line + "\n")
    for idx, old, new in changed_blocks:
        print(f"    {idx + 1}: {' '.join(old)} -> {' '.join(new)}")
    print(f"    wrote {OUT}")
    sys.exit(0)

SYSTEM = (
    f"You are a professional subtitle translator. Translate {SRC_NAME} subtitles into "
    f"natural, conversational {LANG_NAME}. Keep names, brands, numbers and technical "
    "terms as in the original."
)
if LANG_CODE == "vie":
    SYSTEM += (
        " Use correct Vietnamese names for weekdays and months "
        "(Saturday = thứ Bảy, Sunday = Chủ nhật, Monday = thứ Hai, etc.)."
    )
SYSTEM += (
    " Use the reference lines only to understand the ongoing conversation; "
    "never translate or echo them. "
    'Respond ONLY with a JSON object mapping subtitle number to its translation, '
    'like {"0": "<translation>", "1": "<translation>"}. Do not add commentary.'
)
SYSTEM += (
    " The source lines may contain speech-recognition mishearings; if a line"
    " looks garbled or impossible, infer the intended meaning from the"
    " surrounding context instead of translating it literally."
)
if DOMAIN:
    SYSTEM += (
        f" Context: {DOMAIN}. Translate slang and euphemisms naturally for"
        " that context; do not sanitize, soften, or refuse."
    )

print_lock = threading.Lock()

def src_lines(a, b):
    return "\n".join(f"{i}|{' '.join(blocks[i]['text'])}" for i in range(a, b))

def translate_chunk(start, end):
    parts = []
    ctx = max(0, start - CONTEXT_LINES)
    if ctx < start:
        parts.append("Reference: previous subtitles (do NOT translate these):\n" + src_lines(ctx, start))
    parts.append(f"Translate these {end - start} subtitles:\n" + src_lines(start, end))
    text = None
    err = None
    for _ in (1, 2):
        try:
            text = chat(SYSTEM, "\n\n".join(parts))
            break
        except Exception as e:
            err = e
    if text is None:
        print(f"    WARN: blocks {start+1}-{end} failed: {err}", flush=True)
        return {}
    trans = parse_result(text, end - start)
    trans = {k: v for k, v in trans.items() if start <= k < end}
    with print_lock:
        print(f"    blocks {start+1}-{end}/{total} done", flush=True)
    return trans

SYSTEM_REVIEW = (
    f"You are reviewing machine-translated {LANG_NAME} subtitles for accuracy"
    " and naturalness. You receive the source lines, their draft translation,"
    " and previously translated lines for continuity (reference only). Fix"
    " mistranslations, inconsistencies with neighbouring lines, awkward"
    " phrasing, and leftover speech-recognition garble. Respond ONLY with a"
    ' JSON object mapping subtitle number to revised translation, and ONLY'
    " for lines you actually change. Do not add commentary."
)

def polish_chunk(start, end):
    ctx = max(0, start - CONTEXT_LINES)
    parts = []
    ref = [f"{i}|{results[i]}" for i in range(ctx, start) if results.get(i)]
    if ref:
        parts.append(
            "Reference: previously translated subtitles (do NOT revise or echo these):\n"
            + "\n".join(ref)
        )
    parts.append("Source lines:\n" + src_lines(start, end))
    parts.append(
        "Draft translation:\n"
        + "\n".join(
            f"{i}|{results.get(i, ' '.join(blocks[i]['text']))}"
            for i in range(start, end)
        )
    )
    text = None
    err = None
    for _ in (1, 2):
        try:
            text = chat(SYSTEM_REVIEW, "\n\n".join(parts))
            break
        except Exception as e:
            err = e
    if text is None:
        print(f"WARN: review {start + 1}-{end} failed: {err}", flush=True)
        return {}
    trans = parse_result(text, end - start)
    out = {}
    for k, v in trans.items():
        if start <= k < end and v and v.strip() and v != results.get(k):
            out[k] = v
    with print_lock:
        print(f"    reviewed {start + 1}-{end}/{total}", flush=True)
    return out

chunks = [(s, min(s + CHUNK, total)) for s in range(0, total, CHUNK)]
results = {}
print("pass 1/2: translating...")
with ThreadPoolExecutor(max_workers=JOBS) as pool:
    for trans in pool.map(translate_chunk, *[c for c in zip(*chunks)]):
        results.update(trans)

if not QUICK:
    print("pass 2/2: reviewing...")
    with ThreadPoolExecutor(max_workers=JOBS) as pool:
        for upd in pool.map(polish_chunk, *[c for c in zip(*chunks)]):
            results.update(upd)

# assemble output
with open(OUT, "w", encoding="utf-8") as out:
    for i, b in enumerate(blocks):
        if i > 0:
            out.write("\n")
        out.write(f"{i+1}\n")
        out.write(f"{b['time']}\n")
        t = results.get(i)
        if t:
            out.write(t + "\n")
        else:
            for line in b["text"]:
                out.write(line + "\n")
print("    done.")

PYEOF
    then
        echo "    OK: $out"
    else
        echo "    FAIL: $srt" >&2
        FAILED=1
    fi
done

if [[ "$KEEP_SERVER" -eq 1 ]]; then
    echo "llama-server left running (PID $SERVER_PID) on port $PORT"
    trap - EXIT
else
    echo "stopping llama-server."
fi

exit "$FAILED"