# Orca (오르카) — GitHub 탑재 가이드

이 저장소는 [Orca](https://www.onorca.dev/)(공식: [stablyai/orca](https://github.com/stablyai/orca), MIT)를 클라우드/리눅스 환경에 설치하고 GitHub에 연동하기 위한 운영 스캐폴드입니다.

Orca는 AI 코딩 에이전트(Claude Code, Codex, OpenCode 등)를 git worktree 단위로 병렬 실행하는 **Agent Development Environment(ADE)** 입니다. 모델 자체가 아니라, 이미 쓰는 에이전트 CLI를 오케스트레이션합니다.

## 선택 근거 (오르카AI / OrcaAI)

| 후보 | 판정 |
| --- | --- |
| **stablyai/orca** (onorca.dev) | **채택** — 한국어 README/커뮤니티에서 “오르카”로 불리며, 데스크톱·Linux AppImage·`orca serve`·GitHub Integrations를 공식 지원 |
| orca-cli/orca | 유사 이름의 Go CLI. 별개 프로젝트로 배제 |
| Microsoft Orca / 기타 ML “Orca” | 다른 제품군 |

## 빠른 시작 (Linux / 이 클라우드 VM) — GitHub에서 설치

```bash
# 1) GitHub 소스 clone + GitHub Releases AppImage
./scripts/install-orca-linux.sh

# 2) 헤드리스 런타임 기동 (포트 6768)
./scripts/serve-orca.sh

# 3) 상태 확인
orca status
```

`install-orca-linux.sh`가 하는 일:

1. `git clone https://github.com/stablyai/orca.git` → `/opt/orca/src`
2. GitHub Releases API로 `orca-linux.AppImage` 다운로드 → `/opt/orca/orca-linux.AppImage`
3. CLI 래퍼 설치 → `/usr/local/bin/orca`, `orca-ide`

설치 위치 / 검증값:

- Upstream clone: `/opt/orca/src` (예: `bbe9a114…`)
- AppImage: `/opt/orca/orca-linux.AppImage` — **v1.4.224**
- CLI: `/usr/local/bin/orca`, `/usr/local/bin/orca-ide`

공식 문서: [Install](https://www.onorca.dev/docs/install) · [Remote / orca serve](https://www.onorca.dev/docs/remote-servers) · [GitHub reviews](https://www.onorca.dev/docs/review/github)

## GitHub에 “탑재”하는 방법 (계정: battlecruse)

Orca 자체는 SaaS에 올리는 앱이 아니라 **로컬/서버 런타임**입니다. GitHub 쪽 탑재는 아래 두 층으로 나뉩니다.

### A. 이 운영 저장소를 `battlecruse/orca-ai`에 올리기

권장 저장소명: **`battlecruse/orca-ai`**. 브랜치: `cursor/orca-ai-github-setup-87b8`.

이 VM에 `gh`가 로그인되어 있으면:

```bash
./scripts/push-to-battlecruse.sh
```

아직 로그인되어 있지 않으면 (현재 클라우드 에이전트 상태):

```bash
# 브라우저에서 github.com에 로그인한 세션은 이 VM으로 전달되지 않습니다.
gh auth login -h github.com   # battlecruse로 인증
./scripts/push-to-battlecruse.sh
```

또는 GitHub 웹에서 빈 repo `orca-ai`를 만든 뒤:

```bash
git remote add github https://github.com/battlecruse/orca-ai.git
git push -u github cursor/orca-ai-github-setup-87b8
# 웹에서 draft PR: cursor/orca-ai-github-setup-87b8 → main
```

### B. Orca 앱 ↔ GitHub 연동 (PR/이슈/Actions)

공식 경로 ([Hosted reviews](https://www.onorca.dev/docs/review/github), [Settings](https://www.onorca.dev/docs/settings)):

1. **데스크톱 Orca**에서 `Settings → Integrations → GitHub OAuth` 연결.
2. 또는 해당 호스트에서 GitHub CLI 로그인 (Orca가 `gh` 자격 증명을 사용):

```bash
gh auth login -h github.com
gh auth status -h github.com
```

3. 저장소를 Orca에 추가한 뒤 Source Control에서 PR 생성·체크·이슈 worktree 생성을 사용.

원격 `orca serve` 호스트에서는 **그 서버에서** `gh auth login`이 필요합니다. 노트북 로그인만으로는 서버에 전달되지 않습니다.

## Windows / D: 드라이브

이 에이전트는 **클라우드 Linux VM**에서 실행 중이며 사용자 PC의 `D:` 드라이브에 직접 접근할 수 없습니다. Windows 설치는:

1. [onorca.dev/download](https://www.onorca.dev/download)에서 Windows x64 installer 다운로드
2. 설치 후 Claude Code / Codex 등 에이전트 CLI를 먼저 로그인
3. Orca에서 로컬 폴더(또는 `D:\…`)를 저장소로 추가
4. `Settings → Integrations`에서 GitHub OAuth

셀프호스트 워커가 PC에 붙으면 D: 작업(에이전트별 폴더 등)을 이어서 할 수 있습니다.

## 배포 참고

- `deploy/orca-serve.service` — systemd 유닛 예시 (`orca serve --port 6768`)
- 외부에서 페어링하려면 Tailscale / SSH 터널 / 리버스 프록시로 `--pairing-address`에 **도달 가능한 주소**를 넣으세요. 방화벽에서 6768을 열어두지 않으면 페어링 URL은 로컬에만 유효합니다.

## 라이선스

Orca 본체는 MIT([stablyai/orca](https://github.com/stablyai/orca)). 이 저장소의 스크립트·문서는 프로젝트 운영용으로 제공합니다.
