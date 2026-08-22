local M = {}

local is_windows = vim.fn.has("win32") == 1

------------------------------------------------------------
-- Ejecutar comando
------------------------------------------------------------

local function run(cmd)
  local result = vim.system(cmd, {
    text = true,
  }):wait()

  if result.code ~= 0 then
    return nil
  end

  local output = vim.trim(result.stdout or "")

  if output == "" then
    return nil
  end

  return output
end

------------------------------------------------------------
-- Buscar java mediante PATH
--
-- Windows:
--   where java
--
-- Linux/macOS:
--   which -a java
------------------------------------------------------------

local function find_java_executables()
  local command

  if is_windows then
    command = { "where", "java" }
  else
    command = { "which", "-a", "java" }
  end

  if vim.fn.executable(command[1]) ~= 1 then
    return {}
  end

  local output = run(command)

  if not output then
    return {}
  end

  local result = {}
  local seen = {}

  for line in output:gmatch("[^\r\n]+") do
    line = vim.trim(line)

    if line ~= "" and not seen[line] then
      seen[line] = true

      if vim.fn.executable(line) == 1 then
        table.insert(result, line)
      end
    end
  end

  return result
end

------------------------------------------------------------
-- JAVA_HOME como candidato adicional
------------------------------------------------------------

local function java_from_java_home()
  local home = vim.env.JAVA_HOME

  if not home or home == "" then
    return nil
  end

  local java =
    is_windows
      and (home .. "/bin/java.exe")
      or (home .. "/bin/java")

  if vim.fn.executable(java) == 1 then
    return vim.fn.fnamemodify(java, ":p")
  end

  return nil
end

------------------------------------------------------------
-- Detectar versión mayor
------------------------------------------------------------

local function get_version(java)
  local result = vim.system({
    java,
    "-version",
  }, {
    text = true,
  }):wait()

  local output =
    (result.stderr or "")
    .. "\n"
    .. (result.stdout or "")

  local version =
    output:match('version%s+"(%d+)')

  if not version then
    version =
      output:match('openjdk%s+(%d+)')
  end

  return version and tonumber(version) or nil
end

------------------------------------------------------------
-- Obtener JAVA_HOME real desde java
------------------------------------------------------------

local function get_home(java)
  local bin =
    vim.fn.fnamemodify(java, ":h")

  local home =
    vim.fn.fnamemodify(bin, ":h")

  if vim.fn.isdirectory(home) == 1 then
    return vim.fn.fnamemodify(home, ":p")
  end

  return nil
end

------------------------------------------------------------
-- Todos los candidatos
------------------------------------------------------------

local function candidates()
  local result = {}

  -- JAVA_HOME es solamente un candidato.
  local env_java = java_from_java_home()

  if env_java then
    table.insert(result, env_java)
  end

  -- PATH es la fuente principal.
  for _, java in ipairs(find_java_executables()) do
    table.insert(result, java)
  end

  return result
end

------------------------------------------------------------
-- Buscar JDK por major version
------------------------------------------------------------

function M.find(version)
  local seen = {}

  for _, java in ipairs(candidates()) do
    if not seen[java] then
      seen[java] = true

      if get_version(java) == version then
        local home = get_home(java)

        if home then
          return {
            version = version,
            java = java,
            home = home,
          }
        end
      end
    end
  end

  return nil
end

------------------------------------------------------------
-- Información de todos los JDK detectados
------------------------------------------------------------

function M.info()
  local result = {}
  local seen = {}

  for _, java in ipairs(candidates()) do
    if not seen[java] then
      seen[java] = true

      table.insert(result, {
        java = java,
        version = get_version(java),
        home = get_home(java),
      })
    end
  end

  return result
end

return M