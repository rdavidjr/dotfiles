return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false, -- load on startup
        build = ":TSUpdate",
        config = function()
            local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
            if ok then
                ts_configs.setup(require "configs.treesitter")
            end
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvchad.configs.lspconfig").defaults()
            require "configs.lspconfig"
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            require "configs.mason-lspconfig"
        end,
    },

    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require "configs.lint"
        end,
    },

    {
        "rshkarin/mason-nvim-lint",
        event = "VeryLazy",
        dependencies = { "mfussenegger/nvim-lint" },
        config = function()
            require "configs.mason-lint"
        end,
    },

    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        config = function()
            require "configs.conform"
        end,
    },

    {
        "zapling/mason-conform.nvim",
        event = "VeryLazy",
        dependencies = { "stevearc/conform.nvim" },
        config = function()
            require "configs.mason-conform"
        end,
    },

    {
        "alexghergh/nvim-tmux-navigation",
        event = "VeryLazy",
        config = function()
            require("configs.nvim-tmux-navigation").setup()
        end,
    },

    {
        "kevinhwang91/nvim-ufo",
        event = "VeryLazy",
        dependencies = { "kevinhwang91/promise-async" },
        config = function()
            require "configs.ufo"
        end,
    },
}
