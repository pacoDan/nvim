-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "md" },
  callback = function()
    -- 1. Desactivar el corrector ortográfico nativo
    vim.opt_local.spell = false

    -- 2. Desactivar absolutamente todos los diagnósticos (LSP, linters, errores visuales)
    -- Nota: En Neovim 0.10+, esta es la sintaxis correcta para apagarlo en el buffer actual (bufnr = 0)
    vim.diagnostic.enable(false, { bufnr = 0 })

    -- 3. Desactivar el autoformateo al guardar de LazyVim para este buffer
    vim.b.autoformat = false
  end,
})
