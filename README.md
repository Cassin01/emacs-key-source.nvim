# emacs-key-source.txt

## Modules

- `inc-search`: A incremental search inspired by spacemacs's `ctrl-s`
- `goto-line`: goto line inspired by emacs `ctrl-g`
- `relative-jump`: repleat a allow movement N times. inspired by emacs `ctrl-g`
- `retrive_till_tail`: kill line to end
- `retrive_first_half`: kill line to begging

## Example

```lua
local emacs_key_source = require("emacs-key-source")
for k, v in pairs({["<c-s>"] = "inc-search",
                   ["<c-g>"] = "goto-line",
                   ["<c-u>"] = "relative-jump",
                   ["<c-k>"] = "retrive_till_tail",
                   ["<m-k>"] = "retrive_first_half"}) do
    vim.api.nvim_set_keymap("i", k, "", {callback = emacs_key_source[v], noremap = true, silent = true, desc = v})
    vim.api.nvim_set_keymap("n", k, "", {callback = emacs_key_source[v], noremap = true, silent = true, desc = v})
end
```

## Features

### inc-search()

#### Supports `smartcase` and `ignorecase`


[case](./images/case.mov)
