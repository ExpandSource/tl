#!/usr/bin/env bash
set -e

VERSION="0.0.1"
REPO="https://github.com/expandsource/tl"
BIN_DIR="${PREFIX:-/usr/local/bin}"
SHARE_DIR="/usr/share/tl/modules"

# ── 색상 ──────────────────────────────────────────
bold="\033[1m"; green="\033[1;32m"; red="\033[31m"; reset="\033[0m"
info()  { echo -e "  ${green}✓${reset} $*"; }
error() { echo -e "  ${red}✗${reset} $*" >&2; exit 1; }

echo -e "\n${bold}tl ${VERSION} installer${reset}\n"

# ── 설치 방식 결정 ─────────────────────────────────
if [[ -f "./tl" && -d "./modules" ]]; then
    # 로컬 빌드에서 실행
    SRC_BIN="./tl"
    SRC_MOD="./modules"
    info "로컬 빌드 감지"
elif command -v curl &>/dev/null; then
    # 릴리즈 tarball 다운로드 (GitHub 릴리즈 시 활성화)
    error "원격 설치는 GitHub 릴리즈 후 지원됩니다. 로컬에서 'make && bash install.sh' 를 사용하세요."
else
    error "curl 이 없습니다."
fi

# ── sudo 필요 여부 판단 ───────────────────────────
if [[ -w "$BIN_DIR" ]]; then
    SUDO=""
else
    SUDO="sudo"
    echo -e "  ${bold}sudo 권한이 필요합니다.${reset}"
fi

# ── 설치 ──────────────────────────────────────────
$SUDO install -Dm755 "$SRC_BIN" "$BIN_DIR/tl"
info "바이너리 설치: $BIN_DIR/tl"

$SUDO mkdir -p "$SHARE_DIR"
$SUDO cp -r "$SRC_MOD/." "$SHARE_DIR/"
info "모듈 설치: $SHARE_DIR"

# ── 완료 ──────────────────────────────────────────
echo -e "\n${bold}설치 완료!${reset}\n"
echo -e "  시작하려면: ${green}tl${reset}"
echo -e "  1단계부터:  ${green}tl 1${reset}\n"
