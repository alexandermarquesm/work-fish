function work --description "Gerencia e abre projetos em seu editor favorito (Cozy Version)"
    # Variáveis universais (Persistentes)
    set -l VAR_DIR WORK_PROJECTS_DIR
    set -l VAR_EDITOR WORK_PROJECTS_EDITOR

    # --- DEFINIÇÃO DE CORES COZY ---
    set -l c_lavender b4befe
    set -l c_sage a6e3a1
    set -l c_rose f38ba8
    set -l c_text cdd6f4
    set -l c_subtext f5e0dc
    set -l c_border 45475a

    # --- FUNÇÃO DE AJUDA ---
    function __work_help -V c_lavender -V c_sage -V c_subtext -V WORK_PROJECTS_DIR -V WORK_PROJECTS_EDITOR -V c_border -V c_text
        set_color $c_lavender
        echo "╭──────────────────────────────────────────────────╮"
        echo "│                📖 GUIA DO WORK                   │"
        echo "╰──────────────────────────────────────────────────╯"
        set_color normal
        
        set_color $c_lavender; printf " [📁] "; set_color $c_text; echo -n "Pasta ativa: "; set_color normal
        if set -q WORK_PROJECTS_DIR
            echo "$WORK_PROJECTS_DIR"
        else
            set_color $c_subtext; echo "Não configurada"; set_color normal
        end

        set_color $c_lavender; printf " [⌨️] "; set_color $c_text; echo -n "Editor ativo: "; set_color normal
        if set -q WORK_PROJECTS_EDITOR
            echo "$WORK_PROJECTS_EDITOR"
        else
            set_color $c_subtext; echo "Não configurado"; set_color normal
        end
        set_color $c_border; echo " ──────────────────────────────────────────────────"; set_color normal

        echo " Uso: work [projeto] [opções]"
        echo
        set_color $c_sage; echo " Comandos Principais:"; set_color normal
        echo "   work             Lista projetos (Busca interativa)"
        echo "   work <nome>      Abre o projeto no seu editor"
        echo "   work -n <nome>   Cria e abre um novo projeto"
        echo "   work -d <nome>   Exclui um projeto (com backup)"
        echo
        set_color $c_subtext; echo " Opções:"; set_color normal
        echo "   work --help      Mostra esta guia"
        echo "   work --new <n>   Cria e abre um novo projeto"
        echo "   work --delete <n> Exclui um projeto (com backup)"
        echo "   work --path      Troca a pasta de projetos"
        echo "   work --editor    Troca o editor padrão"
        echo "   work --reset     Limpa tudo"
        echo
    end

    # --- FUNÇÃO DO PICKER INTERATIVO (COZY) ---
    function __work_picker -V c_border -V c_lavender -V c_text
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

            set_color $c_border >&2; printf "  ╭─%s─╮\n" $line >&2; set_color normal >&2
            for i in (seq $count)
                set_color $c_border >&2; printf "  │ " >&2; set_color normal >&2
                if test $i -eq $current
                    set_color --bold $c_lavender >&2; printf "➜ %-"$max_w"s  " "$options[$i]" >&2; set_color normal >&2
                else
                    set_color $c_text >&2; printf "  %-"$max_w"s  " "$options[$i]" >&2; set_color normal >&2
                end
                set_color $c_border >&2; printf " │\n" >&2; set_color normal >&2
            end
            set_color $c_border >&2; printf "  ╰─%s─╯\n" $line >&2; set_color normal >&2

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
    function __work_set_path -V c_lavender -V c_text -V c_sage
        set_color $c_lavender; printf " [📁] "; set_color $c_text; echo "Configurando pasta de projetos..."; set_color normal
        set -l default_dir "~/projects"
        read -p "set_color $c_sage; printf '      [Pasta] (Padrão: $default_dir): '; set_color normal" input_dir; or return 1
        if test -z "$input_dir"; set input_dir "$default_dir"; end
        set -Ux WORK_PROJECTS_DIR (string replace -r '^~' "$HOME" "$input_dir")
        if not test -d "$WORK_PROJECTS_DIR"; mkdir -p "$WORK_PROJECTS_DIR"; end
        set_color $c_sage; echo "      ✅ Pasta definida: $WORK_PROJECTS_DIR"; set_color normal
    end

    function __work_set_editor -V c_lavender -V c_text -V c_sage
        set_color $c_lavender; printf " [⌨️] "; set_color $c_text; echo "Escolha seu editor favorito:"; set_color normal
        set -l editors antigravity antigravity-ide code codium cursor zed subl lvim lunarvim nvim vim micro nano emacs kate gedit geany gnome-text-editor mousepad
        set -l avail; for e in $editors; if type -q $e; set -a avail $e; end; end
        if test -z "$avail"
            read -p "set_color $c_sage; printf '      [Comando]: '; set_color normal" custom; or return 1
            set -Ux WORK_PROJECTS_EDITOR "$custom"
        else
            set -l chosen (__work_picker $avail)
            if test $status -eq 0
                set -Ux WORK_PROJECTS_EDITOR "$chosen"
                echo; set_color $c_sage; echo "      ✅ Editor definido: $chosen"; set_color normal
            else
                return 1
            end
        end
    end

    function __work_create_project -V c_lavender -V c_text -V c_sage -V c_rose -V WORK_PROJECTS_DIR -V WORK_PROJECTS_EDITOR
        set -l proj_name $argv[1]
        if test -z "$proj_name"
            set_color $c_rose; echo "❌ Nome do projeto não fornecido. Uso: work --new <nome>"; set_color normal
            return 1
        end

        set -l project_path "$WORK_PROJECTS_DIR/$proj_name"
        if test -d "$project_path"
            set_color $c_rose; echo "❌ O projeto '$proj_name' já existe em $WORK_PROJECTS_DIR"; set_color normal
            return 1
        end

        set_color $c_lavender; printf " [🛠️] "; set_color $c_text; echo "Criando projeto '$proj_name'..."; set_color normal
        mkdir -p "$project_path"
        if not test -d "$project_path"
            set_color $c_rose; echo "❌ Não foi possível criar o diretório $project_path"; set_color normal
            return 1
        end

        if type -q git
            read -p "set_color $c_sage; printf '      [Git] Deseja inicializar o repositório Git? (s/N): '; set_color normal" init_git
            if test "$init_git" = "s" -o "$init_git" = "S" -o "$init_git" = "sim" -o "$init_git" = "Sim" -o "$init_git" = "y" -o "$init_git" = "Y"
                git -C "$project_path" init >/dev/null
                set_color $c_sage; echo "      ✅ Repositório Git inicializado."; set_color normal
            end
        end

        set_color $c_sage; echo "      ✅ Projeto criado com sucesso!"; set_color normal
        echo

        set_color $c_lavender; echo "🍵 Abrindo '$proj_name'..."; set_color normal
        cd "$project_path"
        $WORK_PROJECTS_EDITOR .
    end

    function __work_delete_project -V c_lavender -V c_text -V c_sage -V c_rose -V WORK_PROJECTS_DIR
        set -l proj_name $argv[1]
        if test -z "$proj_name"
            set_color $c_rose; echo "❌ Nome do projeto não fornecido. Uso: work --delete <nome>"; set_color normal
            return 1
        end

        set -l project_path "$WORK_PROJECTS_DIR/$proj_name"
        if not test -d "$project_path"
            set_color $c_rose; echo "❌ O projeto '$proj_name' não existe em $WORK_PROJECTS_DIR"; set_color normal
            return 1
        end

        read -p "set_color $c_rose; printf '⚠️  Tem certeza que deseja excluir o projeto \'$proj_name\'? (s/N): '; set_color normal" confirm
        if not test "$confirm" = "s" -o "$confirm" = "S" -o "$confirm" = "sim" -o "$confirm" = "Sim" -o "$confirm" = "y" -o "$confirm" = "Y"
            set_color $c_sage; echo "      ❌ Exclusão cancelada."; set_color normal
            return 0
        end

        set -l backup_dir "/tmp/work_backups"
        mkdir -p "$backup_dir"

        set -l timestamp (date +%Y%m%d_%H%M%S)
        set -l backup_path "$backup_dir/"$proj_name"_$timestamp"

        set_color $c_lavender; printf " [📦] "; set_color $c_text; echo "Criando backup em $backup_path..."; set_color normal
        cp -r "$project_path" "$backup_path"
        if not test -d "$backup_path"
            set_color $c_rose; echo "❌ Falha ao criar o backup. Abortando exclusão."; set_color normal
            return 1
        end

        set_color $c_lavender; printf " [🗑️] "; set_color $c_text; echo "Excluindo projeto '$proj_name'..."; set_color normal
        rm -rf "$project_path"

        set_color $c_sage; echo "      ✅ Projeto excluído com sucesso!"; set_color normal
        set_color $c_text; echo "      💡 Backup disponível em: $backup_path"; set_color normal
    end

    # --- LÓGICA PRINCIPAL ---
    switch "$argv[1]"
        case "-h" "--help"; __work_help; return 0
        case "--reset"; set -e WORK_PROJECTS_DIR; set -e WORK_PROJECTS_EDITOR; echo "♻️  Configurações limpas."; return 0
        case "--path"; __work_set_path; return 0
        case "--editor"; __work_set_editor; return 0
    end

    if not set -q WORK_PROJECTS_DIR; or not set -q WORK_PROJECTS_EDITOR
        set_color $c_lavender; echo "╭──── ✨ CONFIGURAÇÃO COZY ✨ ────╮"; set_color normal
        set_color $c_border; echo " (Pressione Ctrl+C para sair)"; set_color normal
        echo
        __work_set_path; or begin; echo; return 1; end
        echo
        __work_set_editor; or begin; echo; return 1; end
        echo; set_color $c_sage; echo " ✨ Tudo pronto! Bons códigos. ✨"; set_color normal; echo
        return 0
    end

    switch "$argv[1]"
        case "-n" "--new"
            __work_create_project $argv[2]
            return $status
        case "-d" "--delete"
            __work_delete_project $argv[2]
            return $status
    end

    if count $argv > /dev/null
        set -l project_path "$WORK_PROJECTS_DIR/$argv[1]"
        if test -d "$project_path"
            set_color $c_lavender; echo "🍵 Abrindo '$argv[1]'..."; set_color normal
            cd "$project_path"
            $WORK_PROJECTS_EDITOR .
        else
            set_color $c_rose; echo "❌ Projeto '$argv[1]' não encontrado em $WORK_PROJECTS_DIR"; set_color normal
        end
    else
        set -l project_list (find "$WORK_PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
        if test -z "$project_list"
            set_color $c_rose; echo "📂 Nenhuma pasta encontrada em $WORK_PROJECTS_DIR"; set_color normal
            return 1
        end
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
