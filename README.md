instalacion en linux
```sh
git clone https://github.com/pacodan/nvim ~/.config/nvim
nvim --headless "+Lazy! sync" +qa # Lazy.nvim 
```

instalacion de windows:
```ps1
git clone https://github.com/pacoDan/nvim.git $env:LOCALAPPDATA\nvim
# Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force
nvim --headless "+Lazy! sync" +qa # Lazy.nvim 
```

cuando se clonó por http
```sh
git remote set-url origin git@github.com:pacodan/nvim.git
``
```
para evitar el mason y usar el jdtls para jdk 17
linux
```sh
mkdir -p ~/.local/share/nvim/jdtls && tar -xzf jdt-language-server-1.43.0-202412191447.tar.gz -C ~/.local/share/nvim/jdtls --strip-components=1
```
