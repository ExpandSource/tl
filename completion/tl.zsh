#compdef tl
# tl zsh completion
# 설치: 이 파일을 $fpath 경로에 복사
#   sudo cp tl.zsh /usr/share/zsh/site-functions/_tl
#   또는 ~/.zshrc 에: fpath=(~/.zsh/completions $fpath)

_tl() {
    local -a subcmds cats modules

    subcmds=(
        'n:다음 모듈'
        'next:다음 모듈'
        'p:이전 모듈'
        'prev:이전 모듈'
        'z:마지막으로 본 모듈'
        'last:마지막으로 본 모듈'
        'list:전체 모듈 목록'
    )

    cats=(
        '1:First Steps'
        '2:Files & Dirs'
        '3:Text Editing'
        '4:Permissions'
        '5:Search & Pipe'
        '6:Processes'
        '7:Packages'
        '8:Network'
        '9:Your Environment'
        '10:Scripting'
        '11:System Admin'
    )

    modules=(
        'shell:쉘이란? bash/zsh 개념'
        'prompt:프롬프트 읽는 법'
        'shortcut:쉘 필수 단축키'
        'history:명령어 히스토리'
        'man:도움말 보기'
        'fhs:리눅스 폴더 구조'
        'path:절대경로 vs 상대경로'
        'pwd:현재 위치 확인'
        'cd:디렉토리 이동'
        'ls:목록 보기'
        'mkdir:디렉토리 생성'
        'cp:복사'
        'mv:이동·이름 변경'
        'rm:삭제'
        'ln:링크 (심볼릭·하드)'
        'cat:파일 내용 출력'
        'less:페이지 단위로 보기'
        'head-tail:앞/뒤 줄만 보기'
        'nano:nano 기본 조작'
        'vi:vi/vim 기본 조작'
        'vi-nav:vi 이동·검색·삭제'
        'redirect:출력 저장 (>, >>)'
        'perm:권한 표기 읽기'
        'chmod:권한 변경'
        'chown:소유자 변경'
        'sudo:관리자 권한 실행'
        'su:사용자 전환'
        'pipe:파이프 개념과 철학'
        'grep:텍스트 검색'
        'find:파일 검색'
        'sort-uniq:정렬·중복 제거'
        'wc:줄/단어/글자 수 세기'
        'cut-awk:필드 추출'
        'xargs:파이프 결과를 인수로'
        'ps:프로세스 목록'
        'top:실시간 모니터링'
        'kill:프로세스 종료'
        'bg-fg:백그라운드/포그라운드'
        'jobs:잡 목록'
        'systemctl:서비스 시작·중지'
        'apt:apt 기본 (Debian/Ubuntu)'
        'apt-adv:apt 심화·lock 해결'
        'dnf:dnf 기본 (RHEL/Fedora)'
        'snap:snap 패키지'
        'ip:IP 주소 확인'
        'ping:연결 확인'
        'ssh:원격 접속'
        'ssh-key:SSH 키 생성·등록'
        'scp:원격 파일 복사'
        'curl:HTTP 요청'
        'netstat:포트·연결 상태'
        'dotfile:dotfile이란?'
        'env:환경변수·$PATH 구조'
        'alias:alias 등록·관리'
        'zsh:zsh 설치·기본 설정'
        'omzsh:oh-my-zsh 설치·플러그인'
        'p10k:Powerlevel10k 꾸미기'
        'tmux:tmux 기초'
        'tmux-conf:tmux 설정 커스터마이징'
        'fzf:fzf 설치·활용'
        'nvim:neovim 입문'
        'nvim-plug:neovim 플러그인 관리'
        'shebang:스크립트 작성 기초'
        'var:변수 선언·특수변수'
        'if:조건문'
        'loop:반복문'
        'func:함수 선언·호출'
        'cron:주기적 실행'
        'disk:디스크 사용량'
        'mount:파티션 마운트'
        'user:사용자·그룹 관리'
        'log:로그 확인'
        'firewall:방화벽 기초'
        'crontab:시스템/사용자 cron'
    )

    local state
    _arguments \
        '1: :->first' \
        '2: :->second' \
        && return 0

    case $state in
        first)
            _describe 'command' subcmds
            _describe 'category' cats
            _describe 'module' modules
            ;;
        second)
            case $words[2] in
                1)  _describe 'module' '(1 2 3 4 5)' ;;
                2)  _describe 'module' '(1 2 3 4 5 6 7 8 9 10)' ;;
                3)  _describe 'module' '(1 2 3 4 5 6 7)' ;;
                4)  _describe 'module' '(1 2 3 4 5)' ;;
                5)  _describe 'module' '(1 2 3 4 5 6 7)' ;;
                6)  _describe 'module' '(1 2 3 4 5 6)' ;;
                7)  _describe 'module' '(1 2 3 4)' ;;
                8)  _describe 'module' '(1 2 3 4 5 6 7)' ;;
                9)  _describe 'module' '(1 2 3 4 5 6 7 8 9 10 11)' ;;
                10) _describe 'module' '(1 2 3 4 5 6)' ;;
                11) _describe 'module' '(1 2 3 4 5 6)' ;;
            esac
            ;;
    esac
}

_tl
