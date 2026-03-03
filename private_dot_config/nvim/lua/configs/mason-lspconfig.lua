local servers = {
    "lua_ls",
    "clangd",
    "pyright",
}

require("mason-lspconfig").setup {
    ensure_installed = servers,
    automatic_installation = false,
}
