# Automatic cleanup on uninstallation
# This script listens for the 'work_uninstall' event triggered by Fisher/OMF

function _work_uninstall --on-event work_uninstall
    set -e WORK_PROJECTS_DIR
    set -e WORK_PROJECTS_EDITOR
    
    # Optional: Feedback message (will appear during fisher remove)
    set_color f5e0dc # Rose (Catppuccin)
    echo " 🍵 'work-fish' foi removido e as configurações foram limpas. Até a próxima!"
    set_color normal
end
