return {
  {
    "mfussenegger/nvim-lint",

    event = {
      "BufReadPost",
      "BufNewFile",
    },

    config = function()
      local lint = require("lint")
      local java = require("config.java")

      ------------------------------------------------------------
      -- Checkstyle SIEMPRE con JDK 21
      ------------------------------------------------------------

      local jdk21 = java.find(21)

      if not jdk21 then
        vim.notify(
          "No se encontró JDK 21 para Checkstyle.",
          vim.log.levels.ERROR
        )
        return
      end

      ------------------------------------------------------------
      -- Paths de Checkstyle
      ------------------------------------------------------------

      local config_dir =
        vim.fn.stdpath("config")

      local checkstyle_jar =
        config_dir
        .. "/checkstyle/checkstyle-11.1.0-all.jar"

      local google_checks =
        config_dir
        .. "/checkstyle/google_checks_checkstyle-checkstyle-11.1.0.xml"

      ------------------------------------------------------------
      -- Linter
      ------------------------------------------------------------

      lint.linters.checkstyle = {
        name = "checkstyle",

        cmd = jdk21.java,

        args = {
          "-jar",
          checkstyle_jar,

          "-c",
          google_checks,

          "-f",
          "plain",

          function()
            return vim.api.nvim_buf_get_name(0)
          end,
        },

        stdin = false,
        append_fname = false,

        stream = "stdout",
        ignore_exitcode = true,

        parser = function(output)
          local diagnostics = {}

          for line in vim.gsplit(
            output,
            "\n",
            { plain = true }
          ) do
            local severity, file, lnum, col, message, check =
              line:match(
                "^%[(%u+)%]%s+(.+):(%d+):(%d+):%s+(.-)%s+%[([^%]]+)%]%s*$"
              )

            if severity and lnum and col then
              local level =
                vim.diagnostic.severity.WARN

              if severity == "ERROR" then
                level =
                  vim.diagnostic.severity.ERROR
              elseif severity == "INFO" then
                level =
                  vim.diagnostic.severity.INFO
              end

              table.insert(diagnostics, {
                lnum = tonumber(lnum) - 1,

                col = math.max(
                  tonumber(col) - 1,
                  0
                ),

                end_lnum =
                  tonumber(lnum) - 1,

                end_col =
                  tonumber(col),

                message =
                  message .. " [" .. check .. "]",

                severity = level,

                source = "checkstyle",
              })
            end
          end

          return diagnostics
        end,
      }

      lint.linters_by_ft.java = {
        "checkstyle",
      }
    end,
  },
}