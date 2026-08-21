local M = {}

local is_windows = vim.fn.has("win32") == 1
local is_unix = vim.fn.has("unix") == 1

------------------------------------------------------------
-- Ejecutable para buscar Java
------------------------------------------------------------

local function java_command()
  if is_windows then
    return "where"
  elseif is_unix then
    return "which"
  end

  return nil
end

------------------------------------------------------------
-- Buscar todos los java disponibles en PATH
------------------------------------------------------------

local function find_java_executables()
  local command = java_command()

  if not command then
    return {}
  end

  local output = vim.fn.system({
    command,
    "java",
  })

  if vim.v.shell_error ~= 0 then
    return {}
  end

  local result = {}

  for line in vim.gsplit(output, "\n", { plain = true }) do
    line = vim.trim(line)

    if line ~= "" then
      table.insert(result, line)
    end
  end

  return result
end

------------------------------------------------------------
-- Obtener versión real del java
------------------------------------------------------------

local function get_java_version(java)
  local output = vim.fn.system({
    java,
    "-version",
  })

  -- java -version suele escribir en stderr.
  -- system() captura la salida combinada en Neovim.
  --
  -- Ejemplos:
  --
  -- openjdk version "17.0.15"
  -- openjdk version "21.0.7"
  --
  -- java version "17.0.12"
  --

  local version = output:match('version%s+"(%d+)')

  if not version then
    version = output:match('openjdk%s+version%s+"(%d+)')
  end

  return tonumber(version)
end

------------------------------------------------------------
-- Resolver JDKs
------------------------------------------------------------

local function discover()
  local result = {}

  for _, java in ipairs(find_java_executables()) do
    local version = get_java_version(java)

    if version then
      result[version] = result[version] or {
        java = java,
        home = vim.fs.dirname(
          vim.fs.dirname(java)
        ),
      }
    end
  end

  return result
end

local jdks = discover()

------------------------------------------------------------
-- API
------------------------------------------------------------

function M.get(version)
  return jdks[version]
end

function M.java(version)
  local jdk = jdks[version]

  return jdk and jdk.java or nil
end

function M.home(version)
  local jdk = jdks[version]

  return jdk and jdk.home or nil
end

function M.require(version)
  local jdk = M.get(version)

  if not jdk then
    vim.notify(
      "No se encontró un JDK " .. version .. " mediante PATH",
      vim.log.levels.ERROR
    )

    return nil
  end

  return jdk
end

function M.all()
  return jdks
end

return M