-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- IntelliJ shortcuts
map("n", "<leader>jd", vim.diagnostic.open_float, { desc = "Java: Float diagnostic" })
map("n", "<leader>ja", vim.lsp.buf.code_action, { desc = "Java: Code action" })
map("n", "<leader>jr", vim.lsp.buf.rename, { desc = "Java: Rename" })
map("n", "<leader>jR", "<cmd>JdtRename<cr>", { desc = "Java: JDT Rename" })
map("n", "<leader>jo", "<cmd>JdtOrganizeImports<cr>", { desc = "Java: Organize imports" })
map("n", "<leader>jE", "<cmd>JdtExtractConstant<cr>", { desc = "Java: Extract Constant" })
map("n", "<leader>jV", "<cmd>JdtExtractVariable<cr>", { desc = "Java: Extract Variable" })

-- Debug
map("n", "<F5>", require("dap").continue, { desc = "Debug: Continue" })
map("n", "<F10>", require("dap").step_over, { desc = "Debug: Step Over" })
map("n", "<F11>", require("dap").step_into, { desc = "Debug: Step Into" })
map("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
