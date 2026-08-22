instalacion en linux
```sh
git clone https://github.com/pacodan/nvim ~/.config/nvim
# para evitar el mason y usar el jdtls para jdk 17
mkdir -p ~/.local/share/nvim/jdtls && tar -xzf ~/.config/nvim/jdt-language-server-1.43.0-202412191447.tar.gz -C ~/.local/share/nvim/jdtls --strip-components=1
nvim --headless "+Lazy! sync" +qa # Lazy.nvim 
```

instalacion en windows:
```ps1
git clone https://github.com/pacoDan/nvim.git $env:LOCALAPPDATA\nvim
# Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force
cd $env:LOCALAPPDATA\nvim
# para evitar el mason y usar el jdtls para jdk 17
New-Item -ItemType Directory -Force "$HOME\.local\share\nvim\jdtls"; tar -xzf .\jdt-language-server-1.43.0-202412191447.tar.gz -C "$HOME\.local\share\nvim\jdtls" --strip-components=1
nvim --headless "+Lazy! sync" +qa # Lazy.nvim 
```

cuando se clonó por http
```sh
git remote set-url origin git@github.com:pacodan/nvim.git
```

en windows ver jdks:
```ps1
Get-ChildItem "C:\Program Files\Amazon Corretto" -Directory
```
example:
C:\Program Files\Amazon Corretto\jdk17.0.20_10
C:\Program Files\Amazon Corretto\jdk21.0.12_9


reemplazo de palabras nativo de vim, ejemplo:
```vim
:%s/foo/bar/g
```