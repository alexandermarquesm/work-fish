# 🍵 work-fish

A cozy, interactive project manager for the Fish Shell.

`work` is a productivity tool designed to help you jump between your projects instantly using a beautiful, keyboard-navigable interface. It supports automatic editor detection, fuzzy finding (via `fzf`), and is styled with a soft, cozy Catppuccin-inspired palette.

![Banner](https://raw.githubusercontent.com/alexandermarquesm/work-fish/main/assets/banner.png) *(Note: Add your own screenshot here!)*

## ✨ Features

- **🚀 Instant Setup**: Run `work` for the first time, and it guides you through a cozy configuration wizard.
- **⌨️ Keyboard Navigation**: Select editors using Arrows, `W/S`, or `J/K`.
- **🔍 Fuzzy Search**: Integrated with `fzf` for lightning-fast project switching.
- **🎨 Cozy Aesthetics**: Styled with Lavender, Sage, and Rose pastel colors.
- **🧩 Smart Completions**: Tab-complete your project names and command flags.
- **🛠️ Flexible**: Change your path (`--path`) or editor (`--editor`) anytime.

## 📦 Installation

### Using [fisher](https://github.com/jorgebucaran/fisher) (Recommended)

```fish
fisher install alexandermarquesm/work-fish
```

### Manual Installation

Clone this repository and copy the files:

```fish
cp functions/work.fish ~/.config/fish/functions/
cp completions/work.fish ~/.config/fish/completions/
```

## 🚀 Usage

| Command | Description |
|---|---|
| `work` | Opens the interactive project picker (fzf). |
| `work <project>` | Directly opens a specific project. |
| `work --help` | Shows the interactive guide. |
| `work --path` | Change your projects base directory. |
| `work --editor` | Select a different code editor. |
| `work --reset` | Clear all settings and start fresh. |

## 🍵 Configuration

On the first run, `work` will ask you for:
1. Your projects directory (defaulting to `~/projects`).
2. Your preferred code editor (auto-detects VS Code, Vim, NeoVim, Zed, etc.).

Settings are stored in **Universal Variables** (`set -Ux`), so they persist across sessions without cluttering your config files.

## 🤝 Contributing

Feel free to open issues or pull requests if you have ideas for more "cozy" features!

## 📄 License

MIT © [Alexander Marques](https://github.com/alexandermarquesm)
