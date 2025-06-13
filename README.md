# nvim-telescope-background

### Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- init.lua:
    {
      'AvoidMe/nvim-telescope-background',
      dependencies = { 'nvim-telescope/telescope.nvim' },
    },
```

### Usage

```
require('nvim-telescope-background').setup({})
require('nvim-telescope-background').list_jobs()
require('nvim-telescope-background').start_job({"ls", "-l"})
```
