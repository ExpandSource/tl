# tl bash completion
# 설치: source /usr/share/bash-completion/completions/tl
#   또는 ~/.bashrc 에 source 추가

_tl_completions() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # 서브커맨드
    local subcmds="n next p prev z last list"

    # 카테고리 번호
    local cats="1 2 3 4 5 6 7 8 9 10 11"

    # 모듈명 (tl.conf 기반)
    local modules="shell prompt shortcut history man
        fhs path pwd cd ls mkdir cp mv rm ln
        cat less head-tail nano vi vi-nav redirect
        perm chmod chown sudo su
        pipe grep find sort-uniq wc cut-awk xargs
        ps top kill bg-fg jobs systemctl
        apt apt-adv dnf snap
        ip ping ssh ssh-key scp curl netstat
        dotfile env alias zsh omzsh p10k tmux tmux-conf fzf nvim nvim-plug
        shebang var if loop func cron
        disk mount user log firewall crontab"

    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$subcmds $cats $modules" -- "$cur") )
    elif [[ ${COMP_CWORD} -eq 2 && "$prev" =~ ^[0-9]+$ ]]; then
        # tl 1 <모듈번호> 형태 — 해당 카테고리 모듈 번호
        local cat_modules=""
        case "$prev" in
            1)  cat_modules="1 2 3 4 5" ;;
            2)  cat_modules="1 2 3 4 5 6 7 8 9 10" ;;
            3)  cat_modules="1 2 3 4 5 6 7" ;;
            4)  cat_modules="1 2 3 4 5" ;;
            5)  cat_modules="1 2 3 4 5 6 7" ;;
            6)  cat_modules="1 2 3 4 5 6" ;;
            7)  cat_modules="1 2 3 4" ;;
            8)  cat_modules="1 2 3 4 5 6 7" ;;
            9)  cat_modules="1 2 3 4 5 6 7 8 9 10 11" ;;
            10) cat_modules="1 2 3 4 5 6" ;;
            11) cat_modules="1 2 3 4 5 6" ;;
        esac
        COMPREPLY=( $(compgen -W "$cat_modules" -- "$cur") )
    fi
}

complete -F _tl_completions tl
