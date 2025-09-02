# Lazy-vimpack

> [!WARNING]
> Just for fun, don't expect anything stable.

This plugin is a small wrapper around Nvim's native package manager `vim.pack`
that allows to define plugins as [Lazy.nvim Spec](https://lazy.folke.io/spec).
This includes lazy-loading, local plugins, and more.

> [!IMPORTANT]
> This is not a full replacement for Lazy.nvim. Lazy.nvim is an incredible
> piece of software that does way more than just providing lazy-loading
> options. Don't expect this to be a full Lazy.nvim replacement, but rather a
> familiar way to register your plugins.


## Usage

```lua
-- in your init.lua
vim.pack.add({ { src = 'https://github.com/yochem/lazy-vimpack' } })
require('lazy-vimpack').add({
  {
    'https://github.com/yochem/jq-playground.nvim',
    opts = {
      cmd = { 'yq' }
    }
  },
  {
    'https://github.com/luukvbaal/statuscol.nvim',
    main = 'statuscol',
    init = function ()
      vim.o.number = true
      vim.o.relativenumber = true
    end,
    config = function()
      local builtin = require('statuscol.builtin')
      require('statuscol').setup({
        relculright = true,
        ft_ignore = { 'qf' },
        segments = {
          { sign = { maxwidth = 1, colwidth = 1 }, click = 'v:lua.ScSa' },
          { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
          { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
          {
            sign = { namespace = { 'gitsign' }, fillchar = '│', fillcharhl = '@comment' },
            click = 'v:lua.ScSa',
          },
        },
      })
    end
  },
  'https://github.com/folke/trouble.nvim',
  { 'https://github.com/mcauley-penney/visual-whitespace.nvim', event = 'ModeChanged' },
  { 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'master' },
})

```


## Features

Table legend:
- ✅: Implemented (not covering all edge cases what so ever)
- ➖: Not yet implemented, but should be added
- ❌: Probably won't implement, out of scope

| Spec Property | Implemented    | Details |
| ------------- | -------------- | -------------- |
| [1]           | ✅             | Use full url, owner/repo format not supported.
| dir           | ✅             | Not handled by `vim.pack` but appended to rtp.
| url           | ✅             | Use `src` of `vim.pack.Spec`.
| name          | ✅             | `name` of `vim.pack.Spec`.
| dev           | ❌             |
| dependencies  | ✅             |
| enabled       | ✅             | Same as `cond`.
| cond          | ✅             | Same as `enabled`.
| priority      | ❌             |
| init          | ✅             |
| opts          | ✅             | **Requires `main` to be set.**
| config        | ✅             |
| main          | ✅             | **Required** when using `opts`.
| build         | ➖             |
| lazy          | ❌             |
| event         | ✅             |
| cmd           | ✅             |
| ft            | ✅             |
| keys          | ➖             |
| branch        | ✅             | Use `version` of `vim.pack.Spec`.
| tag           | ✅             | Use `version` of `vim.pack.Spec`.
| commit        | ✅             | Use `version` of `vim.pack.Spec`.
| version       | ✅             | `version` of `vim.pack.Spec`.
| pin           | ✅             |
| submodules    | ❌             |
| optional      | ❌             |
| specs         | ❌             |
| module        | ❌             |
| import        | ❌             |


## Disclaimer

This project is in no way associated with
[Lazy.nvim](https://github.com/folke/lazy.nvim). All credits for designing the
Lazy spec go to @folke.
