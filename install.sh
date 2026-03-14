#!/usr/bin/env bash
set -e

VERSION="0.0.2"
REPO="https://github.com/expandsource/tl"
BIN_DIR="${PREFIX:-/usr/local/bin}"
SHARE_DIR="/usr/share/tl/modules"

# ── 색상 ──────────────────────────────────────────
bold="\033[1m"; green="\033[1;32m"; red="\033[31m"; reset="\033[0m"
info()  { echo -e "  ${green}✓${reset} $*"; }
error() { echo -e "  ${red}✗${reset} $*" >&2; exit 1; }

echo -e "\n${bold}tl ${VERSION} installer${reset}\n"

# ── uninstall ─────────────────────────────────────
if [[ "${1}" == "uninstall" ]]; then
    SUDO=""
    [[ ! -w "$BIN_DIR" ]] && SUDO="sudo"
    $SUDO rm -f  "$BIN_DIR/tl"
    $SUDO rm -rf /usr/share/tl
    $SUDO rm -f  /usr/share/bash-completion/completions/tl
    $SUDO rm -f  /usr/share/zsh/site-functions/_tl
    rm -f "$HOME/.tl_state"
    echo -e "  ${green}✓${reset} 제거 완료"
    exit 0
fi

# ── 설치 방식 결정 ─────────────────────────────────
if [[ -f "./tl" && -d "./modules" ]]; then
    # 로컬 빌드에서 실행
    SRC_BIN="./tl"
    SRC_MOD="./modules"
    SRC_COMP="./completion"
    info "로컬 빌드 감지"
elif command -v curl &>/dev/null; then
    # GitHub Releases에서 최신 tarball 다운로드
    LATEST=$(curl -fsSL "https://api.github.com/repos/expandsource/tl/releases/latest" \
             | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
    [[ -z "$LATEST" ]] && error "최신 버전을 가져올 수 없습니다."
    TARBALL="tl-${LATEST}.tar.gz"
    TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" EXIT
    info "다운로드 중: v${LATEST}"
    curl -fsSL "${REPO}/releases/download/v${LATEST}/${TARBALL}" -o "${TMPDIR}/${TARBALL}"
    tar -xzf "${TMPDIR}/${TARBALL}" -C "${TMPDIR}"
    SRC_BIN="${TMPDIR}/tl-${LATEST}/bin/tl"
    SRC_MOD="${TMPDIR}/tl-${LATEST}/modules"
    SRC_COMP="${TMPDIR}/tl-${LATEST}/completion"
    VERSION="$LATEST"
else
    error "curl 이 없습니다. 'sudo apt install curl' 후 다시 시도하세요."
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

# ── completion 설치 ────────────────────────────────
if [[ -d "$SRC_COMP" ]]; then
    if [[ -d /usr/share/bash-completion/completions ]]; then
        $SUDO install -Dm644 "$SRC_COMP/tl.bash" /usr/share/bash-completion/completions/tl
        info "bash completion 설치"
    fi
    if [[ -d /usr/share/zsh/site-functions ]]; then
        $SUDO install -Dm644 "$SRC_COMP/tl.zsh" /usr/share/zsh/site-functions/_tl
        info "zsh completion 설치"
    fi
fi

# ── 완료 ──────────────────────────────────────────
echo -e "\n${bold}설치 완료!${reset}\n"
echo -e "  시작하려면: ${green}tl${reset}"
echo -e "  1단계부터:  ${green}tl 1${reset}\n"
