return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
    },
    config = function()
      local java_cmd = vim.fn.exepath("java")

      -- 🔥 PATH CORRECTO Amazon Corretto 17 (común en distribuciones)
      local jdk_paths = {
        "/usr/lib/jvm/amazon-corretto-17",
        "/usr/lib/jvm/java-17-amazon-corretto",
        "/usr/lib/jvm/default-java",
        "/usr/lib/jvm/java-17-openjdk",
        vim.fn.expand("$JAVA_HOME") or "",
      }

      local jdk_path = ""
      for _, path in ipairs(jdk_paths) do
        if vim.fn.isdirectory(path) == 1 then
          jdk_path = path
          break
        end
      end

      if jdk_path == "" then
        jdk_path = "/usr/lib/jvm/default-java" -- Fallback
      end

      local jdtls_jar = vim.fn.glob("/usr/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar")
      if jdtls_jar == "" then
        jdtls_jar =
          vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar")
      end

      local cmd = {
        java_cmd,
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx1G",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-jar",
        jdtls_jar,
        "-configuration",
        "/usr/share/java/jdtls/config_linux",
        "-data",
        vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
      }

      vim.notify("🚀 JDTLS | Java: " .. java_cmd, vim.log.levels.INFO)
      vim.notify("🚀 JDTLS | JDK17: " .. jdk_path, vim.log.levels.INFO)

      local config = {
        cmd = cmd,
        root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
        settings = {
          java = {
            configuration = {
              runtimes = {
                {
                  name = "Amazon-Corretto-17",
                  path = jdk_path, -- ✅ PATH CORRECTO
                  default = true,
                },
              },
            },
            completion = {
              favoriteStaticMembers = {
                "org.junit.jupiter.api.Assertions.*",
                "org.mockito.Mockito.*",
                "org.hamcrest.MatcherAssert.assertThat",
                "org.hamcrest.Matchers.*",
              },
            },
            eclipse = { downloadSources = true },
            maven = { downloadSources = true },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
          },
        },
        on_attach = function(client, bufnr)
          require("jdtls.setup").add_commands()
          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "<leader>jo", "<cmd>JdtOrganizeImports<CR>", opts)
          vim.keymap.set("n", "<leader>jR", "<cmd>JdtRename<CR>", opts)
        end,
      }

      require("jdtls").start_or_attach(config)
    end,
  },
}

-- return {
--   {
--     "mfussenegger/nvim-jdtls",
--     ft = { "java" },
--     dependencies = {
--       "neovim/nvim-lspconfig",
--       "mfussenegger/nvim-dap",
--       "williamboman/mason.nvim",
--     },
--     config = function()
--       local config = {
--         cmd = {
--           "java",
--           "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--           "-Dosgi.bundles.defaultStartLevel=4",
--           "-Declipse.product=org.eclipse.jdt.ls.core.product",
--           "-Dlog.protocol=true",
--           "-Dlog.level=ALL",
--           "-Xms1g",
--           "--add-modules=ALL-SYSTEM",
--           "--add-opens",
--           "java.base/java.util=ALL-UNNAMED",
--           "--add-opens",
--           "java.base/java.lang=ALL-UNNAMED",
--           "-jar",
--           vim.fn.glob("/usr/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
--           "-configuration",
--           "/usr/share/java/jdtls/config_linux",
--           "-data",
--           vim.fn.stdpath("cache") .. "/jdtls/workspace",
--         },
--         root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
--         settings = {
--           java = {
--             completion = {
--               favoriteStaticMembers = {
--                 "org.hamcrest.MatcherAssert.assertThat",
--                 "org.hamcrest.Matchers.*",
--                 "org.hamcrest.CoreMatchers.*",
--                 "org.junit.jupiter.api.Assertions.*",
--                 "java.util.Objects.requireNonNull",
--                 "org.mockito.Mockito.*",
--               },
--             },
--             configuration = {
--               runtimes = {
--                 {
--                   name = "Java-21",
--                   path = "/usr/lib/jvm/java-21-openjdk",
--                   default = true,
--                 },
--               },
--             },
--             eclipse = {
--               downloadSources = true,
--             },
--             maven = {
--               downloadSources = true,
--             },
--             implementationsCodeLens = {
--               enabled = true,
--             },
--             referencesCodeLens = {
--               enabled = true,
--             },
--             references = {
--               includeDecompiledSources = true,
--             },
--             signatureHelp = { enabled = true },
--             contentProvider = { preferred = "fernflower" },
--           },
--         },
--       }
--       require("jdtls").start_or_attach(config)
--     end,
--   },
-- }
