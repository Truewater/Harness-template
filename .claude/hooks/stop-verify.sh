#!/usr/bin/env bash
# Stop 훅: 세션이 끝나기 전에 검증 명령을 실행하고, 실패하면 Claude가 멈추지 않고 고치게 한다.
# exit 2 → 종료를 막고 stderr를 Claude에게 전달. exit 0 → 정상 종료.

# ▼ 프로젝트에 맞게 수정 (비워두면 검증 생략). 무거운 build는 step AC에 맡기고 빠른 검증만 두는 것을 권장.
VERIFY_CMD="npm run lint && npm test"

input=$(cat)

# Stop 훅이 이미 한 번 막은 뒤의 재시도라면 통과시켜 무한 루프를 막는다
if echo "$input" | python3 -c 'import json,sys; sys.exit(0 if json.load(sys.stdin).get("stop_hook_active") else 1)' 2>/dev/null; then
  exit 0
fi

[ -z "$VERIFY_CMD" ] && exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# 변경이 없는 턴(질의응답 등)은 검증 생략
if git rev-parse --git-dir >/dev/null 2>&1 && [ -z "$(git status --porcelain)" ]; then
  exit 0
fi

if ! out=$(bash -c "$VERIFY_CMD" 2>&1); then
  echo "검증 실패 ($VERIFY_CMD). 아래 에러를 수정하라:" >&2
  echo "$out" | tail -40 >&2
  exit 2
fi
exit 0
