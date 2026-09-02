#!/usr/bin/env bash
set -euo pipefail

MODEL="$HOME/.local/share/whisper.cpp/ggml-large-v3-turbo-q5_0.bin"
VAD_URL="https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v5.1.2.bin"
VAD_MODEL="${GENSUB_VAD_MODEL:-$HOME/.local/share/whisper.cpp/ggml-silero-v5.1.2.bin}"
WHISPER="whisper-cli"
THREADS="${GENSUB_THREADS:-12}"
LANG_CODE="${GENSUB_LANG:-en}"
VIDEO_EXTS=(mp4 mkv webm mov avi ts flv m4v)
FORCE=0
SOW=0

usage() {
    cat <<EOF
Usage: $0 [-f] [-l lang] <video.mp4 | directory> [more paths...]

Generate SRT subtitles for local videos using whisper.cpp.
Output is written to <name>.<lang>.srt next to each video.

  -f        force re-transcribe even if the .srt already exists
  -l LANG   spoken language code (default: en, e.g. ja vi ko de)
  -w        split on word boundaries (more accurate timestamps, slower;
            ignored for CJK languages ja/zh/ko/th)
  -h        show this help

Examples:
  $0 talk.mp4
  $0 -l ja anime_ep1.mkv
  $0 ~/Videos/
  $0 a.mp4 b.mkv ~/Videos/clips/

Environment overrides: GENSUB_THREADS, GENSUB_LANG, GENSUB_VAD_MODEL

Hallucination guards: Silero VAD strips silence/music/non-speech before
decoding; previous-window text context is disabled (-mc 0) so repetition
loops cannot propagate.
EOF
}

while getopts ":fwl:h" opt; do
    case "$opt" in
        f) FORCE=1 ;;
        w) SOW=1 ;;
        l) LANG_CODE="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

[[ $# -eq 0 ]] && { usage; exit 1; }

# split-on-word assumes space-delimited words; meaningless for CJK
case "$LANG_CODE" in
    ja|zh|ko|th)
        if [[ "$SOW" -eq 1 ]]; then
            echo "note: -w ignored for CJK language '$LANG_CODE'"
            SOW=0
        fi
        ;;
esac

if [[ ! -x "$(command -v "$WHISPER")" ]]; then
    echo "error: $WHISPER not found in PATH" >&2
    exit 1
fi
if [[ ! -f "$MODEL" ]]; then
    echo "error: model not found at $MODEL" >&2
    exit 1
fi

GPU_ARGS=()
HAS_VULKAN_BACKEND=$(strings "$(command -v "$WHISPER")" 2>/dev/null | grep -c "GGML_DISABLE_VULKAN" || true)
if [[ "$HAS_VULKAN_BACKEND" -gt 0 ]] && command -v vulkaninfo >/dev/null 2>&1 && vulkaninfo --summary 2>/dev/null | grep -q "PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU\|PHYSICAL_DEVICE_TYPE_DISCRETE_GPU"; then
    GPU_ARGS=(-dev 0 -fa)
    echo "Vulkan GPU detected: using GPU"
else
    echo "whisper-cli built without GPU backend (or no Vulkan GPU): using CPU ($THREADS threads)"
fi

# don't condition each 30s window on the previous window's text:
# one hallucinated phrase no longer seeds repetition loops
DECODE_ARGS=(-mc 0)

VAD_ARGS=()
if "$WHISPER" --help 2>&1 | grep -q -- "--vad"; then
    if [[ ! -f "$VAD_MODEL" ]]; then
        echo "Silero VAD model not found, downloading..."
        if curl -fsSL --create-dirs -o "$VAD_MODEL" "$VAD_URL"; then
            echo "downloaded: $VAD_MODEL"
        else
            rm -f "$VAD_MODEL"
            echo "warning: VAD download failed" >&2
        fi
    fi
    if [[ -f "$VAD_MODEL" ]]; then
        VAD_ARGS=(-vm "$VAD_MODEL" --vad)
        echo "VAD enabled: non-speech audio is filtered before decoding"
    else
        echo "warning: running without VAD — silence/music may produce hallucinated lines" >&2
    fi
else
    echo "note: whisper-cli has no --vad support; only -mc 0 guard active"
fi

expand_path() {
    local p="$1" ext v
    if [[ -d "$p" ]]; then
        for v in "${VIDEO_EXTS[@]}"; do
            for f in "$p"/*."$v"; do
                [[ -e "$f" ]] && echo "$f"
            done
        done
    else
        ext="${p##*.}"
        for v in "${VIDEO_EXTS[@]}"; do
            [[ "$ext" == "$v" ]] && { echo "$p"; return; }
        done
        echo "skip (unsupported extension): $p" >&2
    fi
}

collect_files() {
    local p
    for p in "$@"; do
        expand_path "$p"
    done
}

mapfile -t FILES < <(collect_files "$@")

[[ ${#FILES[@]} -eq 0 ]] && { echo "no video files found" >&2; exit 1; }

echo "Processing ${#FILES[@]} video(s)..."
FAILED=0

for video in "${FILES[@]}"; do
    base="${video%.*}"
    srt="$base.$LANG_CODE.srt"
    echo
    echo "==> $video"

    if [[ -f "$srt" && "$FORCE" -eq 0 ]]; then
        echo "    skip: $srt already exists (use -f to force)"
        continue
    fi

    tmpwav="$(mktemp /tmp/gen-sub.XXXXXX.wav)"
    trap 'rm -f "$tmpwav"' EXIT

    if ! ffmpeg -y -loglevel error -i "$video" -ar 16000 -ac 1 -vn "$tmpwav"; then
        echo "    FAIL: audio extraction failed" >&2
        FAILED=1
        rm -f "$tmpwav"
        continue
    fi

    SOW_ARGS=()
    [[ "$SOW" -eq 1 ]] && SOW_ARGS=(-sow)

    if ! "$WHISPER" -m "$MODEL" -l "$LANG_CODE" -t "$THREADS" "${GPU_ARGS[@]}" \
            "${DECODE_ARGS[@]}" "${VAD_ARGS[@]}" -osrt \
            -pp "${SOW_ARGS[@]}" -of "$base.$LANG_CODE" "$tmpwav"; then
        echo "    FAIL: transcription failed" >&2
        FAILED=1
        rm -f "$tmpwav"
        continue
    fi

    rm -f "$tmpwav"
    echo "    OK: $srt"
done

echo
if [[ "$FAILED" -eq 1 ]]; then
    echo "Done with errors."
    exit 1
fi
echo "All done."