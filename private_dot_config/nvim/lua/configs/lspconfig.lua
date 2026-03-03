local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- default servers
local default_servers = {
    "pyright",
}

-- Setup default servers
for _, server in ipairs(default_servers) do
    vim.lsp.config(server, {
        on_attach = on_attach,
        on_init = on_init,
        capabilities = capabilities,
    })
end

-- clangd
vim.lsp.config("clangd", {
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = true
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
    cmd = {
        "clangd",
        "--background-index",
        "--query-driver=usr/bin/arm_none_eabi_gcc,/usr/include/newlib",
    },
    on_init = on_init,
    capabilities = capabilities,
})

-- lua_ls
vim.lsp.config("lua_ls", {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                enable = false,
            },
            workspace = {
                library = {
                    vim.fn.expand "$VIMRUNTIME/lua",
                    vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
                    vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
                    vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
                    "${3rd}/love2d/library",
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        },
    },
})
