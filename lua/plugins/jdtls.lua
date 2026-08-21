return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",

    config = function()
      local jdtls = require("jdtls")
      local jdtls_path = vim.fn.expand("~/.local/share/nvim/jdtls")

      -- Java encontrado automáticamente mediante PATH
      local java = vim.fn.exepath("java")

      if java == "" then
        vim.notify("No se encontró Java en PATH", vim.log.levels.ERROR)
        return
      end

      -- Launcher de JDTLS
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

      local group = vim.api.nvim_create_augroup("Jdtls", {
        clear = true,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "java",

        callback = function(args)
          local bufnr = args.buf

          -- Seguridad: jamás arrancar JDTLS fuera de Java
          if vim.bo[bufnr].filetype ~= "java" then
            return
          end

          -- Buscar raíz usando el archivo Java actual
          local root_dir = require("jdtls.setup").find_root({
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

          -- Nombre del proyecto
          local project_name = vim.fn.fnamemodify(root_dir, ":t")

          -- Workspace independiente
          local workspace_dir =
            vim.fn.stdpath("data")
            .. "/jdtls-workspaces/"
            .. project_name

          local config = {
            name = "jdtls",

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

              "-data",
              workspace_dir,
            },

            root_dir = root_dir,

            settings = {
              java = {
                configuration = {
                  runtimes = {},
                },
              },
            },
          }

          jdtls.start_or_attach(config)
        end,
      })
    end,
  },
}