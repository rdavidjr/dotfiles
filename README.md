# dotfiles

Chezmoi-managed personal dotfiles (zsh, Neovim/NvChad customizations, tmux).

## Preferred bootstrap (any OS)

Open [`mycfg.md`](./mycfg.md) in Cursor (or another coding agent) on the target machine and ask it to follow that playbook. It installs packages for Fedora / Ubuntu / macOS, then applies these files with chezmoi.

## Apply configs only

If packages are already installed:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
chezmoi init --apply https://github.com/rdavidjr/dotfiles.git
```

Or with SSH:

```bash
chezmoi init --apply git@github.com:rdavidjr/dotfiles.git
```

## Legacy Ubuntu path

[`rdavidjr/ansible-setup`](https://github.com/rdavidjr/ansible-setup) remains a supported Ubuntu-only installer (`./bootstrap-ansible.sh`). Prefer `mycfg.md` for new machines and for Fedora/macOS.

## Layout

| Source path | Destination |
|-------------|-------------|
| `dot_zshrc` | `~/.zshrc` |
| `private_dot_bashrc` | `~/.bashrc` |
| `private_dot_config/nvim/` | `~/.config/nvim/` |
| `private_dot_config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` |
