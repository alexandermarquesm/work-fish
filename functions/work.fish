function work --description "Gerencia e abre projetos em seu editor favorito (Cozy Version)"
    # Variáveis universais (Persistentes)
    set -l VAR_DIR WORK_PROJECTS_DIR
    set -l VAR_EDITOR WORK_PROJECTS_EDITOR

    # --- DEFINIÇÃO DE CORES COZY (Catppuccin inspired) ---
    set -l color_bg "#1e1e2e"
    set -l color_text "#cdd6f4"
    set -l color_lavender "#b4befe"
    set -l color_sage "#a6e3a1"
    set -l color_rose "#f5e0dc"
    set -l color_border "#45475a"

    # --- FUNÇÃO DE AJUDA ---
    function __work_help
        set_color b4befe # Lavender
        echo "╭──────────────────────────────────────────────────╮"
        echo "│                📖 GUIA DO WORK                   │"
        echo "╰──────────────────────────────────────────────────╯"
        set_color normal
        echo " Uso: work [projeto] [opções]"
        echo
        set_color a6e3a1; echo " Comandos Principais:"; set_color normal
        echo "   work             Lista projetos (Busca interativa)"
        echo "   work <nome>      Abre o projeto no seu editor"
        echo
        set_color f5e0dc; echo " Opções:"; set_color normal
        echo "   work --help      Mostra esta guia"
        echo "   work --path      Troca a pasta de projetos"
        echo "   work --editor    Troca o editor padrão"
        echo "   work --reset     Limpa tudo"
        echo
    end

    # --- FUNÇÃO DO PICKER INTERATIVO (COZY) ---
    function __work_picker
        set -l options $argv
        set -l current 1
        set -l count (count $options)
        set -l first_run 1
        
        set -l max_w 0; for o in $options; set -l len (string length "$o"); if test $len -gt $max_w; set max_w $len; end; end
        set -l inner_w (math "$max_w + 4")
        set -l line (string repeat -n $inner_w "─")

        printf "\e[?25l" >&2
        while true
            if test $first_run -eq 0; printf "\e[%dA" (math "$count + 2") >&2; end
            set first_run 0

            set_color 45475a >&2; printf "  ╭─%s─╮\n" $line >&2; set_color normal >&2
            for i in (seq $count)
                set_color 45475a >&2; printf "  │ " >&2; set_color normal >&2
                if test $i -eq $current
                    set_color --bold b4befe >&2; printf "➜ %-"$max_w"s  " "$options[$i]" >&2; set_color normal >&2
                else
                    set_color cdd6f4 >&2; printf "  %-"$max_w"s  " "$options[$i]" >&2; set_color normal >&2
                end
                set_color 45475a >&2; printf " │\n" >&2; set_color normal >&2
            end
            set_color 45475a >&2; printf "  ╰─%s─╯\n" $line >&2; set_color normal >&2

            stty raw -echo
            set -l key (dd bs=1 count=1 2>/dev/null); if test "$key" = \e; set -l next (dd bs=1 count=2 2>/dev/null); set key "$key$next"; end
            stty -raw echo

            switch "$key"
                case 'w' 'k' \e'[A'
                    set current (math "$current - 1"); if test "$current" -lt 1; set current $count; end
                case 's' 'j' \e'[B'
                    set current (math "$current + 1"); if test "$current" -gt $count; set current 1; end
                case '' \r \n \x0D
                    printf "\e[?25h" >&2; echo $options[$current]; return 0
                case \x03 \x1b
                    printf "\e[?25h" >&2; return 1
            end
        end
    end

    # --- LÓGICA DE CONFIGURAÇÃO ---
    function __work_set_path
        set_color b4befe; printf " [📁] "; set_color text; echo "Configurando pasta de projetos..."; set_color normal
        set -l default_dir "~/projects"
        read -p "      set_color a6e3a1; printf '[Pasta] (Default: $default_dir): '; set_color normal" input_dir
        if test -z "$input_dir"; set input_dir "$default_dir"; end
        set -Ux WORK_PROJECTS_DIR (string replace -r '^~' "$HOME" "$input_dir")
        if not test -d "$WORK_PROJECTS_DIR"; mkdir -p "$WORK_PROJECTS_DIR"; end
        set_color a6e3a1; echo "      ✅ Definido: $WORK_PROJECTS_DIR"; set_color normal
    end

    function __work_set_editor
        set_color b4befe; printf " [⌨️] "; set_color text; echo "Escolha seu editor favorito:"; set_color normal
        set -l editors antigravity code codium cursor zed subl nvim vim micro nano emacs kate gedit geany gnome-text-editor mousepad
        set -l avail; for e in $editors; if type -q $e; set -a avail $e; end; end
        if test -z "$avail"
            read -p "      set_color a6e3a1; printf '      [Comando]: '; set_color normal" custom
            set -Ux WORK_PROJECTS_EDITOR "$custom"
        else
            set -l chosen (__work_picker $avail)
            if test $status -eq 0
                set -Ux WORK_PROJECTS_EDITOR "$chosen"
                echo; set_color a6e3a1; echo "      ✅ Editor definido: $chosen"; set_color normal
            end
        end
    end

    # --- LÓGICA PRINCIPAL ---
    switch "$argv[1]"
        case "-h" "--help"; __work_help; return 0
        case "--reset"; set -e WORK_PROJECTS_DIR; set -e WORK_PROJECTS_EDITOR; echo "♻️  Limpo!"; return 0
        case "--path"; __work_set_path; return 0
        case "--editor"; __work_set_editor; return 0
    end

    if not set -q WORK_PROJECTS_DIR; or not set -q WORK_PROJECTS_EDITOR
        set_color b4befe; echo "╭── ✨ CONFIGURAÇÃO COZY ✨ ──╮"; set_color normal
        __work_set_path; or return 1; echo
        __work_set_editor; or return 1
        echo; set_color a6e3a1; echo " ✨ Tudo pronto! Bons códigos. ✨"; set_color normal; echo
        return 0
    end

    if count $argv > /dev/null
        set -l project_path "$WORK_PROJECTS_DIR/$argv[1]"
        if test -d "$project_path"
            set_color b4befe; echo "🍵 Abrindo '$argv[1]'..."; set_color normal
            cd "$project_path"
            $WORK_PROJECTS_EDITOR .
        else
            set_color rose; echo "❌ Projeto '$argv[1]' não encontrado."; set_color normal
        end
    else
        # LISTAGEM SEGURA (Compatível com ls, eza e espaços)
        set -l project_list (find "$WORK_PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
        
        if type -q fzf
            set -l selection (printf "%s\n" $project_list | fzf \
                --prompt=" 🍵 Projeto: " \
                --height=50% \
                --reverse \
                --border="rounded" \
                --pointer="❯" \
                --color="bg+:-1,fg:#cdd6f4,hl:#f38ba8,fg+:#cdd6f4,bg+:-1,hl+:#f38ba8,info:#cba6f7,prompt:#b4befe,pointer:#f5e0dc,marker:#f5e0dc,spinner:#f5e0dc,header:#f38ba8,border:#45475a")
            
            if test -n "$selection"
                cd "$WORK_PROJECTS_DIR/$selection"
                $WORK_PROJECTS_EDITOR .
            end
        else
            echo "📂 Seus projetos:"
            printf "  • %s\n" $project_list
        end
    end
end
