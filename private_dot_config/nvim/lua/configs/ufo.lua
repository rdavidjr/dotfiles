-- ~/.config/nvim/lua/configs/ufo.lua

local M = {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost", -- Lazy load UFO
    -- Optionally, specify keys for lazy loading if you only want it on specific key presses
    -- keys = {
    --   { "zR", function() require("ufo").openAllFolds() end },
    --   { "zM", function() require("ufo").closeAllFolds() end },
    -- },
    opts = function()
        local ufo = require("ufo")
        -- Set global Vim options related to folding
        vim.o.foldcolumn = "1" -- '0' is not bad
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- Define keymaps for nvim-ufo
        -- vim.keymap.set("n", "zR", ufo.openAllFolds)
        -- vim.keymap.set("n", "zM", ufo.closeAllFolds)
        -- -- You can also define specific fold/unfold for current fold
        -- vim.keymap.set("n", "zr", ufo.openFoldsWith, {
        --     silent = true,
        --     noremap = true,
        --     expr = true,
        --     desc = "Open current fold",
        -- })
        -- vim.keymap.set("n", "zm", ufo.closeFoldsWith, {
        --     silent = true,
        --     noremap = true,
        --     expr = true,
        --     desc = "Close current fold",
        -- })

        -- Configure UFO providers
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
        }

        -- Set up LSP capabilities for existing LSP clients
        for _, ls in ipairs(vim.lsp.get_clients()) do
            ls.set_capabilities(capabilities)
        end

        return {
            -- Provider selector: prioritize LSP, then fallback to treesitter, then indent
            provider_selector = function(bufnr, filetype, buftype)
                -- You might want to exclude certain filetypes from UFO
                if
                    filetype == "help"
                    or filetype == "alpha"
                    or filetype == "dashboard"
                then
                    return ""
                end
                return { "treesitter", "indent" }
            end,
            -- Optional: Custom fold text function
            fold_virt_text_handler = function(
                virtText,
                lnum,
                endLnum,
                width,
                truncate
            )
                local newVirtText = {}
                local suffix = (" 󰁂 %d "):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        -- str width returned from truncate() may less than 2nd argument, need padding
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix
                                .. (" "):rep(
                                    targetWidth - curWidth - chunkWidth
                                )
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, { suffix, "MoreMsg" })
                return newVirtText
            end,
        }
    end,
}

return M
