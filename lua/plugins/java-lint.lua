return {
  {
    "mfussenegger/nvim-lint",

    event = { "BufReadPost", "BufNewFile" },

    config = function()
      local lint = require("lint")

      local config_dir = vim.fn.stdpath("config")

      local checkstyle_jar =
        config_dir .. "/checkstyle/checkstyle-11.1.0-all.jar"

      local google_checks =
        config_dir
          .. "/checkstyle/google_checks_checkstyle-checkstyle-11.1.0.xml"

      ------------------------------------------------------------
      -- Configuración de Checkstyle
      ------------------------------------------------------------

      lint.linters.checkstyle = {
        name = "checkstyle",
        cmd = "java",

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

        parser = function(output, bufnr)
          local diagnostics = {}

          for line in vim.gsplit(output, "\n", { plain = true }) do
            local severity, file, lnum, col, message, check =
              line:match(
                "^%[(%u+)%]%s+(.+):(%d+):(%d+):%s+(.-)%s+%[([^%]]+)%]%s*$"
              )

            if severity and lnum and col and message and check then
              local level = vim.diagnostic.severity.WARN

              if severity == "ERROR" then
                level = vim.diagnostic.severity.ERROR
              elseif severity == "INFO" then
                level = vim.diagnostic.severity.INFO
              end

              table.insert(diagnostics, {
                lnum = tonumber(lnum) - 1,
                col = math.max(tonumber(col) - 1, 0),

                end_lnum = tonumber(lnum) - 1,
                end_col = tonumber(col),

                message = message .. " [" .. check .. "]",

                severity = level,
                source = "checkstyle",
              })
            end
          end

          return diagnostics
        end,
      }

      ------------------------------------------------------------
      -- Java -> Checkstyle
      ------------------------------------------------------------

      lint.linters_by_ft.java = { "checkstyle" }

      ------------------------------------------------------------
      -- Autocommands
      ------------------------------------------------------------

      local group =
        vim.api.nvim_create_augroup("JavaCheckstyle", { clear = true })

      ------------------------------------------------------------
      -- Al abrir un Java
      ------------------------------------------------------------

      vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        pattern = "*.java",

        callback = function(args)
          lint.try_lint("checkstyle", {
            bufnr = args.buf,
          })
        end,
      })

      ------------------------------------------------------------
      -- Al guardar
      ------------------------------------------------------------

      vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = "*.java",

        callback = function(args)
          lint.try_lint("checkstyle", {
            bufnr = args.buf,
          })
        end,
      })

      ------------------------------------------------------------
      -- Mientras editas
      -- Espera 500 ms después del último cambio.
      ------------------------------------------------------------

      local timers = {}

      vim.api.nvim_create_autocmd(
        { "TextChanged", "TextChangedI" },
        {
          group = group,
          pattern = "*.java",

          callback = function(args)
            local bufnr = args.buf

            if timers[bufnr] then
              timers[bufnr]:stop()
              timers[bufnr]:close()
              timers[bufnr] = nil
            end

            timers[bufnr] = vim.defer_fn(function()
              timers[bufnr] = nil

              if vim.api.nvim_buf_is_valid(bufnr)
                  and vim.bo[bufnr].filetype == "java" then
                lint.try_lint("checkstyle", {
                  bufnr = bufnr,
                })
              end
            end, 500)
          end,
        }
      )
    end,
  },
}