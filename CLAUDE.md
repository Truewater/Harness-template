# 프로젝트: {project-name}

{이 프로젝트가 무엇을 하는지 1~2문장. execute.py가 매 step 프롬프트에 이 파일을 주입하므로 짧고 단정하게 쓴다.}

## 기술 스택
- {프레임워크 + 버전}
- {언어 + 설정 (예: TypeScript strict mode)}
- {스타일링}
- {테스트 프레임워크}
- {외부 API / SDK}

## 아키텍처 규칙
<!-- CRITICAL은 "어기면 결과물을 버려야 하는" 규칙에만 붙인다. 가능하면 linter/훅으로도 강제하라 (문장보다 기계가 확실하다). -->
- CRITICAL: {외부 API 호출 위치 제한. 예: 외부 API 호출은 `src/services/`에서만}
- CRITICAL: {비밀값 취급 규칙. 예: API 키는 `src/lib/env.ts`에서만 읽는다, 클라이언트 번들 노출 금지}
- CRITICAL: 테스트에서 실제 외부 API를 호출하지 말 것. 실제 키 없이 테스트가 통과해야 한다.
- {디렉토리별 책임. 예: 컴포넌트는 `src/components/`, 순수 로직은 `src/lib/`}
- {테스트 파일 위치/컨벤션}

## 개발 프로세스
- CRITICAL: 새 기능 구현 시 반드시 테스트를 먼저 작성하고, 테스트가 통과하는 구현을 작성할 것 (TDD)
- 커밋 메시지는 conventional commits 형식을 따를 것 (feat:, fix:, docs:, refactor:)
- 한 세션의 컨텍스트가 30%에 가까워지면 `/handoff`로 인수인계 문서를 남기고 `/clear` 후 `/resume`으로 이어간다.

## 명령어
<!-- step AC, /review, Stop 훅(.claude/hooks/stop-verify.sh의 VERIFY_CMD)이 이 명령들을 기준으로 삼는다. -->
{dev 명령}      # 개발 서버
{build 명령}    # 프로덕션 빌드
{lint 명령}     # 린트
{test 명령}     # 테스트
