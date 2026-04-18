-- return {
--   "mason-org/mason.nvim", -- ✅ Renombrado
--   opts = {
--     ensure_installed = {
--       "jdtls",
--       "java-debug-adapter",
--     },
--   },
-- }
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "jdtls",
        "java-debug-adapter",
        "google-java-format",
        "checkstyle",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "java", "kotlin" })
    end,
  },
}
