-- in your init.lua

vim.opt.rtp:append(vim.fs.normalize('.'))
require('lazy-vimpack').add('testpluginspec')

-- vim.pack.add({ { src = 'https://github.com/yochem/lazy-vimpack' } })

-- require('lazy-vimpack').add({
--   {
--     'https://github.com/yochem/jq-playground.nvim',
--     opts = {
--       cmd = { 'yq' }
--     }
--   },
--   {
--     'https://github.com/luukvbaal/statuscol.nvim',
--     main = 'statuscol',
--     init = function ()
--       vim.o.number = true
--       vim.o.relativenumber = true
--     end,
--     config = function()
--       local builtin = require('statuscol.builtin')
--       require('statuscol').setup({
--         relculright = true,
--         ft_ignore = { 'qf' },
--         segments = {
--           { sign = { maxwidth = 1, colwidth = 1 }, click = 'v:lua.ScSa' },
--           { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
--           { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
--           {
--             sign = { namespace = { 'gitsign' }, fillchar = '│', fillcharhl = '@comment' },
--             click = 'v:lua.ScSa',
--           },
--         },
--       })
--     end
--   },
--   'https://github.com/folke/trouble.nvim',
--   { 'https://github.com/mcauley-penney/visual-whitespace.nvim', event = 'ModeChanged' },
--   { 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'master' },
-- })
