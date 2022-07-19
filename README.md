# emacs-key-source.txt

## Modules

- `inc-search`: A incremental search inspired by spacemacs's `ctrl-s`
- `goto-line`: goto line inspired by emacs `ctrl-g`
- `relative-jump`: repleat a allow movement N times. inspired by emacs `ctrl-g`
- `kill-line2end`: kill line to end (emacs `ctrl-k`)
- `kill-line2begging`: kill line to begging (emacs `esc-k`)

## Install

### packer.nvim

```lua
use { "emacs-key-source.nvim" }
```

## Example

```lua
local emacs_key_source = require("emacs-key-source")
for k, v in pairs({["<c-s>"] = "inc-search",
                   ["<c-g>"] = "goto-line",
                   ["<c-u>"] = "relative-jump",
                   ["<c-k>"] = "kill-line2end",
                   ["<m-k>"] = "kill-line2begging"}) do
    vim.api.nvim_set_keymap("i", k, "", {callback = emacs_key_source[v], noremap = true, silent = true, desc = v})
    vim.api.nvim_set_keymap("n", k, "", {callback = emacs_key_source[v], noremap = true, silent = true, desc = v})
end
```

## Features

### inc-search()

#### Supports `smartcase` and `ignorecase`


![case](./images/case.gif)
