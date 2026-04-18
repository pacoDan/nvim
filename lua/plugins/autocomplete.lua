return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help", -- 🔥 PARÉNTESIS AUTOMÁTICOS
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    opts = function()
      local cmp = require("cmp")
      return {
        completion = {
          completeopt = "menu,menuone,preview,noselect",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          -- 🔥 TAB = Aceptar CON PARÉNTESIS (IntelliJ style)
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              })
            elseif require("luasnip").expand_or_jumpable() then
              require("luasnip").expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require("luasnip").jumpable(-1) then
              require("luasnip").jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        -- 🔥 FUENTES prioritarias (LSP primero)
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- Métodos con ( )
          { name = "nvim_lsp_signature_help" }, -- Ayuda parámetros
          { name = "luasnip" }, -- Snippets
          { name = "buffer" }, -- Buffer
          { name = "path" }, -- Archivos
        }),
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              nvim_lsp_signature_help = "[Sig]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
        experimental = {
          ghost_text = true, -- Preview texto
          native_menu = false,
        },
      }
    end,
  },
}
