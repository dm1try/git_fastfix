# Git FastFix

This is a Neovim plugin for applying "fast git fixups"(using UI) to the current development branch.

![demo](demo.gif)

Under the hood `git commit --fixup` and `git rebase -i --autosquash --autostash` are used, see git manual for the more information.
## Installation

Add plugin to the runtime path

### Vim-Plug 

```VimL
Plug 'dm1try/git_fastfix'

```

load lua module and map `git_fastfix.open()`
```VimL
lua git_fastfix = require('git_fastfix')
nn <silent> <leader>gf :lua git_fastfix.open()<cr>
```

## Development

Install neovim from [source](https://github.com/neovim/neovim#install-from-source).
Run the tests from neovim source directory. Example:
```
cd ~/projects/neovim
TEST_FILE=~/projects/git_fastfix/spec/git_fastfix_spec.lua make functionaltest
```
