# Completions for the 'work' command

function __work_complete_projects
    if set -q WORK_PROJECTS_DIR; and test -d "$WORK_PROJECTS_DIR"
        find "$WORK_PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;
    end
end

# Disable standard file completion
complete -c work -f

# Add project suggestions for the first argument
complete -c work -n "__fish_is_nth_token 1" -a "(__work_complete_projects)" -d "Project"

# Add project suggestions for deletion
complete -c work -n "__fish_prev_arg_in -d --delete" -a "(__work_complete_projects)" -d "Project to delete"

# Add flags
complete -c work -l help -d "Show guide and commands"
complete -c work -s c -l cd -d "Only cd to the project's directory"
complete -c work -s n -l new -d "Create and open a new project"
complete -c work -s d -l delete -d "Delete a project (with backup)"
complete -c work -l path -d "Change projects base directory"
complete -c work -l editor -d "Choose a different code editor"
complete -c work -l reset -d "Wipe all configurations"
