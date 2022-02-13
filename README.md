jump_to_github.nvim
====

### Install
with packer
```lua
use({
  "tacogips/jump_to_github.nvim",
    requires = { { "nvim-lua/plenary.nvim" } },
    config = function()
      require("jump_to_github").setup({})
    end,
})

```


### Usage


```
:JumpToGithub

#  or with selection in visual mode
:'<,'>JumpToGithub
```



