
local M = {}

local augroup = vim.api.nvim_create_augroup('lazy-vimpack', {})

local function value_or_func(val, ...)
	if type(val) ~= 'function' then
		return val
	end

	return val(...)
end

local function do_add(plugin)
	if value_or_func(plugin.enabled) == false then
		return
	end

	if value_or_func(plugin.cond, plugin) == false then
		return
	end

	if type(plugin.init) == 'function' then
		plugin.init(plugin)
	end

	for _, plug in ipairs(plugin.dependencies or {}) do
		do_add(plug)
	end

	if plugin.dir ~= nil then
		vim.opt.rtp:append(plugin.dir)
	else
		---@type vim.pack.Spec
		local spec = {
			src = plugin.src,
			name = plugin.name,
			version = plugin.version,
		}
		vim.pack.add(
            { spec }
            {
                load = function(p)
                    local data = p.spec.data or {}
                    if data.cmd then
                        for _, cmd in ipairs(data.cmd) do
                            vim.api.nvim_create_user_command(
                                cmd,
                                function()
                                    vim.cmd.packadd(p.spec.name)
                                    if p.spec.data and p.spec.data.config then
                                        p.spec.data.config()
                                    end
                                    vim.cmd(cmd)
                                end,
                                {})
                        end
                    else
                        vim.cmd.packadd(p.spec.name)
                    end
                end
            }
        )
	end

	if plugin.config == true and plugin.opts == nil then
		plugin.opts = {}
	end

	local opts = value_or_func(plugin.opts, plugin)
	if type(opts) == 'table' then
		if not plugin.main then
			error('opts requires main to be set')
		end
		require(plugin.main).setup(opts)
	elseif type(plugin.config) == 'function' then
		plugin.config()
	end
end

local function setup_autocmd(plugin, event, pattern)
	vim.api.nvim_create_autocmd(event, {
		once = true,
		pattern = pattern,
		group = augroup,
		desc = 'lazy-load plugins',
		callback = function()
			do_add(plugin)
		end,
	})
end

function M.add(plugins)
	-- load from config files that return specs
	if type(plugins) == 'string' then
		local loadedplugins = {}
		local folder = vim.fs.joinpath(vim.fn.stdpath('config'), 'lua', plugins)
		for file in vim.fs.dir(folder) do
			if vim.endswith(file, '.lua') then
				local x = dofile(vim.fs.joinpath(folder, file))
				if type(x) == 'table' then
					table.insert(loadedplugins, x)
				end
			end
		end
		plugins = loadedplugins
	end

	for _, plugin in ipairs(plugins) do
		if type(plugin) == 'string' then
			plugin = { src = plugin }
		end
		if plugin[1] then
			plugin.src = plugin[1]
		end

		if plugin.event ~= nil then
			setup_autocmd(plugin, plugin.event)
		end
		if plugin.ft ~= nil then
			setup_autocmd(plugin, 'FileType', plugin.ft)
		end
		if vim.F.if_nil(plugin.event, plugin.ft, plugin.lazy) == nil then
			do_add(plugin)
		end
	end
end

return M
