# mycfg — agent machine bootstrap

Give this file to **Cursor** (or another coding agent) running on the target machine and ask it to follow the playbook end-to-end.

**Preferred** multi-OS path (Fedora, Ubuntu, macOS).  
**Legacy Ubuntu-only:** [`rdavidjr/ansible-setup`](https://github.com/rdavidjr/ansible-setup) (`./bootstrap-ansible.sh`) — still supported.

## Goal

Idempotent personal setup matching the author's workstation:

1. Install Layer A (shell/CLI) + Layer B (Neovim/Mason prerequisites).
2. Apply chezmoi dotfiles from `https://github.com/rdavidjr/dotfiles.git`.
3. Run a one-shot Neovim headless sync so Lazy + Mason tools install.
4. Run the verification checklist.
5. **Ask before** Layers C or D.

## Hard constraints

- Prefer distro packages (`dnf` / `apt` / `brew`). Do not invent random install methods.
- **Never** delete or replace `~/.config/nvim` with stock NvChad. Chezmoi owns configs.
- Do not compile tmux from source unless the distro package is missing.
- Be idempotent: safe to re-run; skip steps already satisfied.
- Do not commit or push unless the user asks.
- If a package name is unavailable, say so and pick the closest documented alternative in the matrix.

## Detect OS

| Detect | Package manager |
|--------|-----------------|
| Fedora / RHEL-like (`/etc/os-release` ID fedora, rhel, centos, rocky, alma) | `dnf` |
| Debian / Ubuntu | `apt` |
| macOS (`uname -s` = Darwin) | Homebrew (`brew`); install brew first if missing via https://brew.sh |
| Anything else | Stop and ask the user |

Ensure the user can sudo (Linux) or use brew (macOS).

---

## Layer A — Shell / CLI (always)

Install these logical tools (use the OS matrix below):

| Logical | Fedora (`dnf`) | Ubuntu (`apt`) | macOS (`brew`) |
|---------|----------------|----------------|----------------|
| git | git | git | git |
| curl | curl | curl | curl |
| unzip | unzip | unzip | unzip |
| zsh | zsh | zsh | zsh |
| neovim | neovim | neovim | neovim |
| tmux | tmux | tmux | tmux |
| fzf | fzf | fzf | fzf |
| bat | bat | bat | bat |
| fd | fd-find | fd-find | fd |
| ripgrep | ripgrep | ripgrep | ripgrep |
| lsd | lsd | lsd | lsd |
| lazygit | lazygit | lazygit *(PPA/binary if missing)* | lazygit |
| btop | btop | btop | btop |
| jq | jq | jq | jq |
| tree | tree | tree | tree |
| chezmoi | chezmoi | *(script below if no pkg)* | chezmoi |

**Ubuntu notes**

- Binary for bat may be `batcat`; for fd may be `fdfind`. Dotfiles detect both.
- If `lsd`, `lazygit`, `btop`, or `chezmoi` are missing from default apt, install via the project's recommended method (GitHub release binary into `~/.local/bin`, or official install script for chezmoi). Prefer packages when they exist.

**Chezmoi fallback (any OS without a package):**

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
```

### Shell bootstrap (after packages)

1. Ensure login shell is zsh (`chsh` on Linux; `dscl`/`chsh` on macOS) if not already.
2. Install Oh My Zsh unattended if `~/.oh-my-zsh` is missing:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

3. Clone custom plugins if missing:

```bash
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
```

(`git`, `fzf`, `z`, `docker`, `docker-compose`, `ollama` are stock OMZ plugins; docker/ollama plugins are harmless if those tools are absent.)

### Fonts (Layer A)

Install **JetBrainsMono Nerd Font** into the user fonts directory:

- Linux: `~/.local/share/fonts`
- macOS: `~/Library/Fonts`

Use Nerd Fonts release zip (e.g. v3.4.0+ `JetBrainsMono.zip` from https://github.com/ryanoasis/nerd-fonts/releases). Unzip TTF/OTF files into the fonts dir, then on Linux run `fc-cache -fv`.

---

## Layer B — Neovim / Mason prerequisites (always with A)

| Logical | Fedora | Ubuntu | macOS |
|---------|--------|--------|-------|
| Node.js 22 (preferred) | nodejs22 / nodejs22-npm or `nodejs` ≥ 18 | nodejs npm (NodeSource 22 if needed) | node@22 or node |
| python3 | python3 | python3 | python3 |
| pip / venv | python3-pip python3-devel | python3-pip python3-venv | *(brew python includes pip)* |
| gcc | gcc | build-essential | *(Xcode CLT)* |
| g++ | gcc-c++ | build-essential | *(Xcode CLT)* |
| make | make | make | make |

On macOS, ensure Xcode Command Line Tools: `xcode-select --install` if compilers are missing.

**Why:** Treesitter builds parsers with a C/C++ compiler. Mason installs:

- LSP: `lua_ls`, `clangd`, `pyright`
- Formatters: `stylua`, `clang-format`, `isort`, `black`
- Linters: `luacheck`, `flake8`

---

## Dotfiles apply

```bash
export PATH="$HOME/.local/bin:$PATH"
# Prefer SSH if keys work; otherwise HTTPS
chezmoi init --apply https://github.com/rdavidjr/dotfiles.git
```

If chezmoi source already exists, `chezmoi update` / `chezmoi apply` instead of wiping it.

**Do not** clone NvChad starter into `~/.config/nvim`.

### One-shot Neovim sync

After chezmoi apply:

```bash
nvim --headless "+Lazy! sync" "+MasonInstall lua-language-server clangd pyright stylua clang-format isort black luacheck flake8" "+qa"
```

If MasonInstall fails partially, re-run or open nvim once interactively. Network is required.

### TPM (tmux plugins)

First tmux start installs TPM via config; or:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || true
tmux new-session -d -s _bootstrap 'sleep 1' 2>/dev/null || true
~/.tmux/plugins/tpm/bin/install_plugins 2>/dev/null || true
tmux kill-session -t _bootstrap 2>/dev/null || true
```

---

## Layer C — Build / embedded (optional — ask first)

| Logical | Fedora | Ubuntu | macOS |
|---------|--------|--------|-------|
| cmake | cmake | cmake | cmake |
| ninja | ninja-build | ninja-build | ninja |
| gdb | gdb | gdb | gdb *(or lldb)* |
| ARM none-eabi | arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++ arm-none-eabi-newlib | gcc-arm-none-eabi | arm-none-eabi-gcc |

Matches firmware/embedded work. clangd query-driver in nvim config expects `/usr/bin/arm-none-eabi-gcc` when present.

---

## Layer D — Workstation extras (optional — ask first)

| Item | Notes |
|------|--------|
| Docker Engine + Compose | Official Docker CE docs per OS; add user to `docker` group on Linux |
| VS Code | Vendor repo / `.deb` / brew cask `visual-studio-code` |
| Cursor | Vendor install instructions |
| Ollama | https://ollama.com install script / brew |

OMZ already lists `docker`, `docker-compose`, and `ollama` plugins; they only matter once tools exist.

---

## Verification checklist

Agent must run and report:

```bash
command -v zsh git curl nvim tmux fzf chezmoi
command -v bat batcat 2>/dev/null; command -v fd fdfind 2>/dev/null
command -v lsd lazygit btop jq tree rg
command -v node npm python3 gcc g++ make
echo "SHELL=$SHELL"
test -d "$HOME/.oh-my-zsh"
test -f "$HOME/.zshrc"
test -f "$HOME/.config/nvim/init.lua"
test -f "$HOME/.config/tmux/tmux.conf"
nvim --version | head -1
tmux -V
chezmoi --version
node -v
# Mason bins (after sync):
ls "$HOME/.local/share/nvim/mason/bin" 2>/dev/null | head
```

Expect: zsh default (or noted if user declined chsh), configs present, mason bin dir populated with at least clangd, stylua, pyright (or clear note if install still running).

---

## Suggested agent prompt

> Follow `mycfg.md` in this repo. Install Layers A and B for my OS, apply chezmoi dotfiles, run the Neovim Mason sync, then the verification checklist. Ask me before Layers C or D.
