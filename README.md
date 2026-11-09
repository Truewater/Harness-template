# Harness Template

Claude Code로 "문서 → step 계획 → 자동 실행" 흐름을 돌리기 위한 하네스 시작 파일 모음.
`ai-next-watch`(Ch4-harness_engineering)에서 0-mvp phase를 돌리며 검증한 구성을 스택 중립적으로 정리했다.

## 구성

| 경로 | 역할 | 새 프로젝트에서 할 일 |
|---|---|---|
| `CLAUDE.md` | 프로젝트 규칙. 매 세션 자동 로드 + execute.py가 step 프롬프트에 주입 | `{...}` 채우기 |
| `docs/PRD.md` | 무엇을, 누구를 위해, 무엇은 안 만드는가 | 채우기 |
| `docs/ARCHITECTURE.md` | 디렉토리 구조, 데이터 흐름, API 계약 | 채우기 |
| `docs/ADR.md` | 기술 결정과 이유 | 채우기 |
| `docs/UI_GUIDE.md` | UI 규칙, AI 슬롭 금지 목록 | UI 없으면 삭제 |
| `.claude/commands/harness.md` | `/harness` — 탐색 → 논의 → step 설계 → 파일 생성 → 실행 | 그대로 |
| `.claude/commands/review.md` | `/review` — 문서 기준 변경 리뷰 | 그대로 |
| `.claude/commands/handoff.md` | `/handoff` — `/clear` 전 인수인계 문서 작성 | 그대로 |
| `.claude/commands/resume.md` | `/resume` — 인수인계 문서로 새 세션 재개 | 그대로 |
| `.claude/settings.json` | 훅 등록 | 그대로 |
| `.claude/hooks/block-dangerous.sh` | 위험한 Bash 명령 차단 (exit 2) | 필요시 패턴 추가 |
| `.claude/hooks/stop-verify.sh` | 세션 종료 전 검증, 실패 시 계속 고치게 함 | **`VERIFY_CMD` 수정** |
| `.claude/hooks/tdd-guard.sh` | Edit/Write 시 테스트 파일 없는 구현 코드(.ts/.tsx/.js/.jsx) 작성 차단. `package.json` 생기기 전엔 비활성, `jq` 필요 | 스택에 맞게 예외 패턴 조정 |
| `scripts/execute.py` | phase의 step을 순차 실행하는 하네스 | 그대로 |
| `scripts/test_execute.py` | execute.py 테스트 (`uvx pytest scripts/test_execute.py`) | 그대로 |
| `phases/index.json` | phase 목록 (비어 있음) | 그대로 |
| `.gitignore`, `.env.example` | step 산출물·키·런타임 상태 제외 | 스택별 항목 추가 |

## 사용법

```bash
# 1. 새 프로젝트에 복사 (숨김 파일 포함)
cp -R /Users/jinsoo/Projects/Study1/harness-template/. ~/Projects/my-app/
cd ~/Projects/my-app && git init

# 2. CLAUDE.md, docs/*.md의 {...} 채우기  (Claude와 대화하며 채워도 된다)
# 3. .claude/hooks/stop-verify.sh의 VERIFY_CMD를 프로젝트 명령으로 수정
# 4. 문서를 커밋한 뒤 Claude Code에서:
/harness            # 문서를 읽고 논의 → step 계획 → phases/ 파일 생성
python3 scripts/execute.py 0-mvp   # step 순차 자동 실행 (feat-0-mvp 브랜치)
/review             # 결과 리뷰
```

## 운영 원칙

- **문서가 가드레일이다.** execute.py는 CLAUDE.md와 `docs/*.md` 전체를 매 step에 주입한다. 문서에 없는 결정은 step 세션이 임의로 내린다. 쓸모없는 문서는 컨텍스트만 먹으니 지운다.
- **규칙은 가능하면 기계로.** CLAUDE.md의 CRITICAL 규칙 중 grep/linter로 잡을 수 있는 것(금지 import, 금지 환경변수 접두사 등)은 linter 규칙으로 옮기면 Stop 훅과 AC가 자동으로 잡는다.
- **컨텍스트 예산 30%.** step은 한 세션이 context window의 30% 안에서 끝나도록 쪼갠다. 대화형 세션에서 예산에 다가가면 `/handoff` → `/clear` → `/resume`.
- **작업 트리를 깨끗이 하고 실행.** execute.py는 `git add -A`로 커밋하므로, 실행 전 커밋 안 된 변경은 step 0 커밋에 섞인다.

## 원본 대비 변경점

- 훅: 입력을 stdin JSON에서 읽고 `exit 2`로 실제 차단. 원본은 `$CLAUDE_TOOL_INPUT`(존재하지 않음) + `exit 1`이라 아무것도 막지 못했다.
- Stop 훅: `stop_hook_active`로 무한 루프 방지, 변경 없는 턴은 검증 생략, 실패 시 `exit 2`로 계속 고치게 함.
- execute.py: step 세션에게 "직접 커밋하지 마라"로 지시. 원본은 세션이 직접 커밋해서 feat 커밋에 index.json이 섞였다.
- `.gitignore`: `**/.omc/*`로 하위 폴더의 런타임 상태까지 제외.
- `/harness`: 컨텍스트 예산 원칙(8번) 추가, 명령어를 CLAUDE.md 참조로 일반화.
- `/review`: 비교 기준(`main...HEAD`) 명시, lint·build·test를 직접 실행하게 함.

## 알려진 개선 과제 (execute.py)

- step이 `completed`라고 자기 보고하면 그대로 믿는다. 하네스가 AC를 직접 실행해 검증하도록 바꾸는 게 좋다.
- `claude -p` 타임아웃(`TimeoutExpired`)을 잡지 않아 하네스가 traceback과 함께 죽는다.
- 시작 시 작업 트리가 깨끗한지 확인하지 않고, 브랜치를 main이 아닌 현재 HEAD에서 딴다.
- output JSON의 비용·턴 수·최대 컨텍스트(`usage.iterations[-1]`)를 index.json에 기록하지 않는다.
