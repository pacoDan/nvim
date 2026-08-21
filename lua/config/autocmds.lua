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
--
-- ------------------------------------------------------------
-- -- Diagnósticos
-- --
-- -- Mostrar normalmente durante 5 segundos y después
-- -- ocultarlos visualmente.
-- --
-- -- IMPORTANTE:
-- -- NO se utiliza vim.diagnostic.open_float().
-- -- Por lo tanto no aparecen ventanas flotantes.
-- ------------------------------------------------------------
--
-- local diagnostic_timers = {}
--
-- vim.api.nvim_create_autocmd("DiagnosticChanged", {
--   callback = function(args)
--     local bufnr = args.buf
--
--     if not vim.api.nvim_buf_is_valid(bufnr) then
--       return
--     end
--
--     -- Cancelar el temporizador anterior de este buffer
--     if diagnostic_timers[bufnr] then
--       diagnostic_timers[bufnr]:stop()
--       diagnostic_timers[bufnr]:close()
--       diagnostic_timers[bufnr] = nil
--     end
--
--     -- Si no hay diagnósticos, no hacemos nada
--     local diagnostics = vim.diagnostic.get(bufnr)
--
--     if #diagnostics == 0 then
--       return
--     end
--
--     -- Mostrar todos los diagnósticos normalmente
--     vim.diagnostic.show(nil, bufnr)
--
--     -- Ocultarlos después de 5 segundos
--     diagnostic_timers[bufnr] = vim.defer_fn(function()
--       diagnostic_timers[bufnr] = nil
--
--       if vim.api.nvim_buf_is_valid(bufnr) then
--         vim.diagnostic.hide(nil, bufnr)
--       end
--     end, 5000)
--   end,
-- })
--
-- ------------------------------------------------------------
-- -- Limpiar timers cuando se elimina un buffer
-- ------------------------------------------------------------
--
-- vim.api.nvim_create_autocmd("BufDelete", {
--   callback = function(args)
--     local bufnr = args.buf
--
--     if diagnostic_timers[bufnr] then
--       diagnostic_timers[bufnr]:stop()
--       diagnostic_timers[bufnr]:close()
--       diagnostic_timers[bufnr] = nil
--     end
--   end,
-- })
