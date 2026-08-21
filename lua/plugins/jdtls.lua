return {
  {
    "mfussenegger/nvim-jdtls",

    ft = "java",

    config = function()
      local jdtls = require("jdtls")
      local jdtls_setup = require("jdtls.setup")

      local jdtls_path = vim.fn.expand("~/.local/share/nvim/jdtls")

      ------------------------------------------------------------
      -- Java
      ------------------------------------------------------------

      local java = vim.fn.exepath("java")

      if java == "" then
        vim.notify(
          "JDTLS: no se encontró java en PATH",
          vim.log.levels.ERROR
        )
        return
      end

      ------------------------------------------------------------
      -- Launcher
      ------------------------------------------------------------

      local launcher = vim.fn.glob(
        jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"
      )

      if launcher == "" then
        vim.notify(
          "JDTLS: no se encontró el launcher en " .. jdtls_path,
          vim.log.levels.ERROR
        )
        return
      end

      ------------------------------------------------------------
      -- Configuración común
      ------------------------------------------------------------

      local config = {
        cmd = {
          java,

          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",

          "-Dlog.protocol=true",
          "-Dlog.level=ALL",

          "-Xms1g",

          "--add-modules=ALL-SYSTEM",

          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",

          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",

          "-jar",
          launcher,

          "-configuration",
          jdtls_path .. "/config_linux",
        },

        settings = {
          java = {
            configuration = {
              runtimes = {},
            },

            maven = {
              downloadSources = true,
            },

            references = {
              includeDecompiledSources = true,
            },

            implementationsCodeLens = {
              enabled = true,
            },

            referencesCodeLens = {
              enabled = true,
            },
          },
        },

        on_attach = function(client, bufnr)
          --------------------------------------------------------
          -- Confirmación
          --------------------------------------------------------

          vim.notify(
            "JDTLS conectado: "
              .. vim.api.nvim_buf_get_name(bufnr),
            vim.log.levels.INFO
          )

          --------------------------------------------------------
          -- Java refactoring
          --------------------------------------------------------

          vim.keymap.set("n", "<leader>je", function()
            jdtls.extract_variable()
          end, {
            buffer = bufnr,
            silent = true,
            desc = "Java: Extract Variable",
          })

          vim.keymap.set("v", "<leader>je", function()
            jdtls.extract_variable(true)
          end, {
            buffer = bufnr,
            silent = true,
            desc = "Java: Extract Variable",
          })

          vim.keymap.set("v", "<leader>jm", function()
            jdtls.extract_method(true)
          end, {
            buffer = bufnr,
            silent = true,
            desc = "Java: Extract Method",
          })

          vim.keymap.set("n", "<leader>jc", function()
            jdtls.extract_constant()
          end, {
            buffer = bufnr,
            silent = true,
            desc = "Java: Extract Constant",
          })

          --------------------------------------------------------
          -- Imports
          --------------------------------------------------------

          vim.keymap.set("n", "<leader>jo", function()
            jdtls.organize_imports()
          end, {
            buffer = bufnr,
            silent = true,
            desc = "Java: Organize Imports",
          })

          --------------------------------------------------------
          -- Code Action
          --------------------------------------------------------

          vim.keymap.set("n", "<leader>ja", vim.lsp.buf.code_action, {
            buffer = bufnr,
            silent = true,
            desc = "Java: Code Action",
          })

          --------------------------------------------------------
          -- Rename
          --------------------------------------------------------

          vim.keymap.set("n", "<leader>jr", vim.lsp.buf.rename, {
            buffer = bufnr,
            silent = true,
            desc = "Java: Rename",
          })
        end,
      }

      ------------------------------------------------------------
      -- MUY IMPORTANTE:
      --
      -- start_or_attach se ejecuta por CADA archivo Java.
      ------------------------------------------------------------

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",

        group = vim.api.nvim_create_augroup(
          "Jdtls",
          { clear = true }
        ),

        callback = function(args)
          local bufnr = args.buf

          --------------------------------------------------------
          -- Encontrar raíz del proyecto desde ESTE buffer
          --------------------------------------------------------

          local root_dir = jdtls_setup.find_root({
            ".git",
            "mvnw",
            "gradlew",
            "pom.xml",
            "build.gradle",
            "build.gradle.kts",
          })

          if not root_dir then
            vim.notify(
              "JDTLS: no se encontró raíz para "
                .. vim.api.nvim_buf_get_name(bufnr),
              vim.log.levels.WARN
            )
            return
          end

          --------------------------------------------------------
          -- Workspace
          --------------------------------------------------------

          local project_name =
            vim.fn.fnamemodify(root_dir, ":t")

          local workspace_dir =
            vim.fn.stdpath("data")
            .. "/jdtls-workspaces/"
            .. project_name

          --------------------------------------------------------
          -- Config específica de ESTE proyecto/buffer
          --------------------------------------------------------

          local buffer_config = vim.deepcopy(config)

          buffer_config.root_dir = root_dir

          buffer_config.cmd = vim.deepcopy(config.cmd)

          table.insert(buffer_config.cmd, "-data")
          table.insert(buffer_config.cmd, workspace_dir)

          --------------------------------------------------------
          -- Arrancar o adjuntar JDTLS
          --------------------------------------------------------

          jdtls.start_or_attach(buffer_config)
        end,
      })
    end,
  },
}