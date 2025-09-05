local M = {}

---@class lazy-vimpack.ExtraSpec
---@field dir string?
---@field dependencies string[]?
---@field enabled boolean?
---@field cond boolean?
---@field init fun(Spec)?
---@field opts table?
---@field config fun(Spec)?
---@field main string?
---@field build string|fun(Spec)?
---@field event string[]|string?
---@field cmd string[]|string?
---@field ft string[]|string?

---@class Spec: vim.pack.Spec
---@field data lazy-vimpack.ExtraSpec

local augroup = vim.api.nvim_create_augroup('lazy-vimpack', {})

local function value_or_func(val, ...)
	return type(val) == 'function' and val(...) or val
end


---@param p string|table
---@return Spec
local function resolve_spec(p)
	if type(p) == 'string' then
		return { src = p }
	end

	local r = {}

	if p[1] then
		r.src = p[1]
		p[1] = nil
	end

	r.name = p.name
	p.name = nil

	r.version = p.version
	p.version = nil

	r.data = vim.deepcopy(p)

	return r
end


---@param plugin Spec
local function handle_opts_config(plugin)
	local opts = plugin.data.opts
	local conf = plugin.data.config
	local main = plugin.data.main

	if conf == true and opts == nil then
		opts = {}
	end

	opts = value_or_func(opts, plugin)
	if type(opts) == 'table' then
		if not main then
			error('opts requires main to be set')
		end
		require(main).setup(opts)
	elseif type(conf) == 'function' then
		conf(plugin)
	end
end


---@param plugin Spec
local function packadd(plugin)
	if type(plugin.data.init) == 'function' then
		plugin.data.init(plugin)
	end

	if type(plugin.data.dependencies) == 'table' then
		M.add(plugin.data.dependencies)
	end

	-- TODO: handle local plugins

	vim.cmd.packadd(plugin.name)

	handle_opts_config(plugin)
end


local function setup_autocmd(plugin, event, pattern)
	vim.api.nvim_create_autocmd(event, {
		once = true,
		pattern = pattern,
		group = augroup,
		desc = 'lazy-load plugins',
		callback = function()
			packadd(plugin)
		end,
	})
end


---@param plugin Spec
local function handle_event(plugin)
	local event = plugin.data.event
	if type(event) ~= 'table' then
		event = { event }
	end
	for _, ev in ipairs(event) do
		setup_autocmd(plugin, ev)
	end
end


---@param plugin Spec
local function handle_ft(plugin)
	local ft = plugin.data.ft
	if type(ft) ~= 'table' then
		ft = { ft }
	end
	for _, i_ft in ipairs(ft) do
		setup_autocmd(plugin, 'FileType', i_ft)
	end
end


---@param plugin Spec
local function handle_cmd(plugin)
	local cmds = plugin.data.cmd
	if type(cmds) ~= 'table' then
		cmds = { cmds }
	end
	for _, cmd in ipairs(cmds) do
		vim.api.nvim_create_user_command(cmd, function ()
			packadd(plugin)
			vim.api.nvim_del_user_command(cmd)
			vim.cmd(cmd)
		end, {})
	end
end


---@param plugin Spec
local function handle_build(plugin)
	local build = plugin.data.build
	vim.api.nvim_create_autocmd('PackChanged', {
		pattern = '*/' .. vim.fs.basename(plugin.name or plugin.src),
		group = augroup,
		callback = function(ev)
			if ev.data.spec.kind ~= 'deleted' then
				if type(build) == 'string' then
					vim.cmd(build)
				elseif type(build) == 'function' then
					build(plugin)
				end
			end
		end,
	})
end


---@param plugin Spec
local function load_plugin(plugin)
	if value_or_func(plugin.data.enabled) == false then
		return
	end

	if value_or_func(plugin.data.cond, plugin) == false then
		return
	end

	-- NOTE: if-guards actually not needed, but that's a current implementation
	-- detail of the handle_[event|ft|cmd] functions.
	local lazy = false
	if plugin.data.event then
		handle_event(plugin)
		lazy = true
	end

	if plugin.data.ft then
		handle_ft(plugin)
		lazy = true
	end

	if plugin.data.cmd then
		handle_cmd(plugin)
		lazy = true
	end

	if not lazy then
		packadd(plugin)
	end
end


local function dir_of_specs(dir)
	local loadedplugins = {}
	local folder = vim.fs.joinpath(vim.fn.stdpath('config'), 'lua', dir)
	for file in vim.fs.dir(folder) do
		if vim.endswith(file, '.lua') then
			local x = dofile(vim.fs.joinpath(folder, file))
			if type(x) == 'table' then
				table.insert(loadedplugins, x)
			end
		end
	end
	return loadedplugins
end


function M.add(plugins)
	-- load from config files that return specs
	if type(plugins) == 'string' then
		plugins = dir_of_specs(plugins)
	end

	for _, plugin in ipairs(plugins) do
		local spec = resolve_spec(plugin)
		local load = #plugin.data > 0 and load_plugin or nil
		vim.pack.add({ spec }, { confirm = false, load = load })
	end
end


return M
