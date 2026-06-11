require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

vim.keymap.set("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", { silent = true })
vim.keymap.set(
    "n",
    "<C-l>",
    "<Cmd>NvimTmuxNavigateRight<CR>",
    { silent = true }
)
-- vim.keymap.set("n", "<C-\\>", "<Cmd>NvimTmuxNavigateLastActive<CR>", { silent = true })
-- vim.keymap.set("n", "<C-Space>", "<Cmd>NvimTmuxNavigateNavigateNext<CR>", { silent = true })

-- Override <leader>fw to search the word under cursor across the project
-- map("n", "<leader>fw", function()
--     require("telescope.builtin").grep_string()
-- end, { desc = "Telescope search word under cursor" })

-- Alternative: If you want live_grep but pre-filled with the word under cursor
map("n", "<leader>fw", function()
    require("telescope.builtin").live_grep {
        default_text = vim.fn.expand "<cword>",
    }
end, { desc = "Telescope live grep with word under cursor" })
