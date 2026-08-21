return {
  {
    "mfussenegger/nvim-jdtls",

    ft = "java",

    config = function()
      local jdtls = require("jdtls")
      local java = require("config.java")

      ------------------------------------------------------------
      -- JDKs
      ------------------------------------------------------------

      local jdk17 = java.require(17)
      local jdk21 = java.require(21)

      if not jdk17 or not jdk21 then
        return
      end

      ------------------------------------------------------------
      -- JDTLS
      --
      -- JDTLS corre con Java 21.
      ------------------------------------------------------------

      local jdtls_path =
        vim.fn.expand("~/.local/share/nvim/jdtls")

      local launcher = vim.fn.glob(
        jdtls_path
          .. "/plugins/org.eclipse.equinox.launcher_*.jar"
      )

      if launcher == "" then
        vim.notify(
          "No se encontró el launcher de JDTLS en "
            .. jdtls_path,
          vim.log.levels.ERROR
        )

        return
      end

      ------------------------------------------------------------
      -- Autocmd
      ------------------------------------------------------------

      local group = vim.api.nvim_create_augroup(
        "Jdtls",
        { clear = true }
      )

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "java",

        callback = function(args)
          local bufnr = args.buf

          if vim.bo[bufnr].filetype ~= "java" then
            return
          end

          ----------------------------------------------------------
          -- Root
          ----------------------------------------------------------

          local root_dir =
            require("jdtls.setup").find_root({
              "mvnw",
              "gradlew",
              "pom.xml",
              "build.gradle",
              "build.gradle.kts",
              ".git",
            }, vim.api.nvim_buf_get_name(bufnr))

          if not root_dir then
            vim.notify(
              "No se encontró la raíz del proyecto Java",
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
          -- JDTLS
          ----------------------------------------------------------

          local config = {
            name = "jdtls",

            --------------------------------------------------------
            -- JDTLS corre con Java 21
            --------------------------------------------------------

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
              jdtls_path .. "/config_win",

              "-data",
              workspace_dir,
            },

            root_dir = root_dir,

            --------------------------------------------------------
            -- JDKs disponibles para los proyectos
            --------------------------------------------------------

            settings = {
              java = {
                configuration = {
                  runtimes = {
                    {
                      name = "JavaSE-17",
                      path = jdk17.home,
                      default = true,
                    },

                    {
                      name = "JavaSE-21",
                      path = jdk21.home,
                    },
                  },
                },
              },
            },
          }

          vim.notify(
            "JDTLS iniciado con Java 21",
            vim.log.levels.INFO
          )

          jdtls.start_or_attach(config)
        end,
      })
    end,
  },
}