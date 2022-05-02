local M = {}
local path = require("libp.path")

local oldfiles_path = path.join(vim.fn.stdpath("data"), "oldfiles")
local oldfiles

function M.setup(opts)
	vim.validate({ opts = { opts, "t", true } })
	opts = opts or { cache_size = 1000 }
	oldfiles = require("libp.datatype.Lru")(1000)

	if vim.fn.filereadable(oldfiles_path) ~= 0 then
		local paths = vim.fn.readfile(oldfiles_path)
		require("libp.log").warn(paths)
		for i = #paths, 1, -1 do
			require("libp.log").warn(i, paths[i])
			oldfiles:add(paths[i])
		end
	end

	local oldfiles_aug = vim.api.nvim_create_augroup("OLDFILES", {})
	vim.api.nvim_create_autocmd("VimLeave", {
		group = oldfiles_aug,
		callback = function()
			if oldfiles then
				vim.fn.writefile(oldfiles:values(), oldfiles_path)
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "BufRead", "BufWritePost" }, {
		group = oldfiles_aug,
		pattern = "*",
		callback = function(arg)
			oldfiles:add(arg.match)
		end,
	})
end

function M.oldfiles()
	return oldfiles:values()
end

return M
