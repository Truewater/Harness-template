#!/usr/bin/env bash
# PreToolUse(Bash) 훅: 위험한 명령을 차단한다.
# Claude Code는 도구 입력을 stdin JSON으로 전달하며, exit 2만 실제 차단으로 처리된다 (exit 1은 경고만 남김).
# execute.py는 --dangerously-skip-permissions로 실행되므로 이 훅이 사실상 유일한 안전장치다.

cmd=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)

patterns=(
  'rm[[:space:]]+(-[a-zA-Z]*[rR][a-zA-Z]*[fF]|-[a-zA-Z]*[fF][a-zA-Z]*[rR])'  # rm -rf, rm -fr, rm -Rf ...
  'rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*-[rR]([[:space:]]|$).*-f|rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*-f([[:space:]]|$).*-[rR]'  # rm -r -f
  'git[[:space:]]+push[[:space:]].*(--force|-f([[:space:]]|$))'
  'git[[:space:]]+reset[[:space:]]+--hard'
  'git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f'
  'git[[:space:]]+checkout[[:space:]]+(--[[:space:]]+)?\.([[:space:]]|$)'
  'DROP[[:space:]]+(TABLE|DATABASE)'
)

for p in "${patterns[@]}"; do
  if echo "$cmd" | grep -qiE "$p"; then
    echo "BLOCKED: 위험한 명령어가 감지되었습니다 ($cmd). 다른 방법을 사용하거나 사용자에게 직접 실행을 요청하라." >&2
    exit 2
  fi
done
exit 0
