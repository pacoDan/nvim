return {
  {
    "mfussenegger/nvim-jdtls",

    ft = "java",

    config = function()
      local jdtls = require("jdtls")
      local java = require("config.java")

      ------------------------------------------------------------
      -- JDK 21 = JVM que ejecuta JDTLS
      ------------------------------------------------------------

      local jdk21 = java.find(21)

      if not jdk21 then
        vim.notify(
          "No se encontró JDK 21. JDTLS no puede iniciarse.",
          vim.log.levels.ERROR
        )
        return
      end

      ------------------------------------------------------------
      -- JDK 17 = runtime por defecto de los proyectos
      ------------------------------------------------------------

      local jdk17 = java.find(17)

      ------------------------------------------------------------
      -- JDTLS
      ------------------------------------------------------------

      local jdtls_path =
        vim.fn.expand("~/.local/share/nvim/jdtls")

      local launcher = vim.fn.glob(
        jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"
      )

      if launcher == "" then
        vim.notify(
          "No se encontró el launcher de JDTLS en " .. jdtls_path,
          vim.log.levels.ERROR
        )
        return
      end

      ------------------------------------------------------------
      -- Configuración según SO
      ------------------------------------------------------------

      local jdtls_config

      if vim.fn.has("win32") == 1 then
        jdtls_config = jdtls_path .. "/config_win"
      elseif vim.fn.has("mac") == 1 then
        jdtls_config = jdtls_path .. "/config_mac"
      elseif vim.fn.has("unix") == 1 then
        jdtls_config = jdtls_path .. "/config_linux"
      else
        vim.notify(
          "Sistema operativo no soportado por JDTLS.",
          vim.log.levels.ERROR
        )
        return
      end

      ------------------------------------------------------------
      -- Root
      ------------------------------------------------------------

      local root_markers = {
        "mvnw",
        "gradlew",
        "pom.xml",
        "build.gradle",
        "build.gradle.kts",
        ".git",
      }

      ------------------------------------------------------------
      -- JDTLS
      ------------------------------------------------------------

      local group = vim.api.nvim_create_augroup(
        "JavaJdtls",
        { clear = true }
      )

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "java",

        callback = function(args)
          local bufnr = args.buf

          ----------------------------------------------------------
          -- Evitar iniciar otro cliente si ya existe
          ----------------------------------------------------------

          for _, client in ipairs(
            vim.lsp.get_clients({
              bufnr = bufnr,
              name = "jdtls",
            })
          ) do
            return
          end

          ----------------------------------------------------------
          -- Root
          ----------------------------------------------------------

          local root_dir =
            require("jdtls.setup").find_root(
              root_markers,
              vim.api.nvim_buf_get_name(bufnr)
            )

          if not root_dir then
            vim.notify(
              "No se encontró la raíz del proyecto Java.",
              vim.log.levels.WARN
            )
            return
          end

          ----------------------------------------------------------
          -- Workspace
          ----------------------------------------------------------

          local project_name =
            vim.fn.fnamemodify(root_dir, ":t")

          local workspace_dir =
            vim.fn.stdpath("data")
            .. "/jdtls-workspaces/"
            .. project_name

          ----------------------------------------------------------
          -- Runtimes
          ----------------------------------------------------------

          local runtimes = {}

          if jdk17 then
            table.insert(runtimes, {
              name = "JavaSE-17",
              path = jdk17.home,
              default = true,
            })
          end

          table.insert(runtimes, {
            name = "JavaSE-21",
            path = jdk21.home,
          })

          ----------------------------------------------------------
          -- JDTLS
          ----------------------------------------------------------

          local config = {
            name = "jdtls",

            cmd = {
              jdk21.java,

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
              jdtls_config,

              "-data",
              workspace_dir,
            },

            root_dir = root_dir,

            init_options = {
              extendedClientCapabilities =
                jdtls.extendedClientCapabilities,
            },

            settings = {
              java = {
                configuration = {
                  runtimes = runtimes,
                },
              },
            },
          }

          jdtls.start_or_attach(config)
        end,
      })

      ------------------------------------------------------------
      -- Mappings LSP / JDTLS
      ------------------------------------------------------------

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup(
          "JavaJdtlsMappings",
          { clear = true }
        ),

        callback = function(args)
          local client =
            vim.lsp.get_client_by_id(args.data.client_id)

          if not client or client.name ~= "jdtls" then
            return
          end

          local opts = {
            buffer = args.buf,
            silent = true,
          }

          ----------------------------------------------------------
          -- LSP estándar
          ----------------------------------------------------------

          vim.keymap.set(
            "n",
            "cr",
            vim.lsp.buf.rename,
            vim.tbl_extend("force", opts, {
              desc = "Rename",
            })
          )

          vim.keymap.set(
            "n",
            "<leader>ca",
            vim.lsp.buf.code_action,
            vim.tbl_extend("force", opts, {
              desc = "Code Action / Refactor",
            })
          )

          vim.keymap.set(
            "n",
            "gd",
            vim.lsp.buf.definition,
            vim.tbl_extend("force", opts, {
              desc = "Go to Definition",
            })
          )

          vim.keymap.set(
            "n",
            "gr",
            vim.lsp.buf.references,
            vim.tbl_extend("force", opts, {
              desc = "References",
            })
          )

          ----------------------------------------------------------
          -- JDTLS
          ----------------------------------------------------------

          vim.keymap.set(
            "n",
            "<leader>jo",
            jdtls.organize_imports,
            vim.tbl_extend("force", opts, {
              desc = "Java: Organize Imports",
            })
          )

          ----------------------------------------------------------
          -- Extract Variable
          ----------------------------------------------------------

          vim.keymap.set(
            "v",
            "<leader>jv",
            function()
              jdtls.extract_variable(true)
            end,
            vim.tbl_extend("force", opts, {
              desc = "Java: Extract Variable",
            })
          )

          ----------------------------------------------------------
          -- Extract Constant
          ----------------------------------------------------------

          vim.keymap.set(
            "v",
            "<leader>jc",
            function()
              jdtls.extract_constant(true)
            end,
            vim.tbl_extend("force", opts, {
              desc = "Java: Extract Constant",
            })
          )

          ----------------------------------------------------------
          -- Extract Method
          ----------------------------------------------------------

          vim.keymap.set(
            "v",
            "<leader>jm",
            function()
              jdtls.extract_method(true)
            end,
            vim.tbl_extend("force", opts, {
              desc = "Java: Extract Method",
            })
          )
        end,
      })
    end,
  },
}