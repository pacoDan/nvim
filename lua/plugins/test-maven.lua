return {
  config = function()
    -- 🔥 F5 = mvn test SOLO archivo actual (solo terminal nativo)
    vim.keymap.set("n", "<F5>", function()
      if vim.fn.filereadable("pom.xml") == 0 and vim.fn.filereadable("build.gradle") == 0 then
        vim.notify("❌ No es proyecto Maven/Gradle", vim.log.levels.ERROR)
        return
      end

      local test_file = vim.fn.expand("%:t:r")
      local cmd = "mvn test -Dtest=" .. test_file .. " -DfailIfNoTests=false"

      -- Terminal nativo (siempre funciona)
      vim.cmd("botright 12new")
      vim.cmd("terminal " .. cmd)
    end, { desc = "🧪 F5: mvn test archivo actual" })

    -- F6 = mvn test método bajo cursor
    vim.keymap.set("n", "<F6>", function()
      if vim.fn.filereadable("pom.xml") == 0 then
        return
      end

      local test_method = vim.fn.expand("<cword>")
      local test_file = vim.fn.expand("%:t:r")
      local cmd = string.format("mvn test -Dtest=%s#%s -DfailIfNoTests=false", test_file, test_method)

      vim.cmd("botright 12new")
      vim.cmd("terminal " .. cmd)
    end, { desc = "🧪 F6: mvn test método" })

    -- F7 = mvn test manual
    vim.keymap.set("n", "<F7>", function()
      vim.ui.input({ prompt = "Test class: " }, function(input)
        if input and vim.fn.filereadable("pom.xml") == 1 then
          local cmd = "mvn test -Dtest=" .. input
          vim.cmd("botright 12new | terminal " .. cmd)
        end
      end)
    end, { desc = "🧪 F7: mvn test manual" })
  end,
}
