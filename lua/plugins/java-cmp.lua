return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")
    opts.sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "nvim_lsp_signature_help" },
      { name = "luasnip" },
      { name = "buffer" },
    })

    -- 🔥 Snippets JAVA específicos
    require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./java-snippets" } })
  end,
}
