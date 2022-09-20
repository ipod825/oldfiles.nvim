local M = {}
local pathfn = require("libp.utils.pathfn")

local oldfiles_path = pathfn.join(vim.fn.stdpath("data"), "oldfiles")
local oldfiles

function M.setup(opts)
	vim.validate({ opts = { opts, "t", true } })
	opts = opts or { cache_size = 1000 }
	oldfiles = require("libp.datatype.LruList")(1000)

	if vim.fn.filereadable(oldfiles_path) ~= 0 then
		local paths = vim.fn.readfile(oldfiles_path)
		for i = #paths, 1, -1 do
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
