local M = {}

function M.setup()
    require("nvim-tmux-navigation").setup({
        disable_when_zoomed = true, -- Optional: Keep navigation within Neovim if tmux pane is zoomed
        keybindings = {
            left = "<C-h>",
            down = "<C-j>",
            up = "<C-k>",
            right = "<C-l>",
            -- last_active = "<C-\\",
            -- next = "<C-Space>",
        },
    })
end

return M
