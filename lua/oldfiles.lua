local M = {}
local path = require("libp.utils.path")

local oldfiles_path = path.path_join(vim.fn.stdpath("data"), "oldfiles")
local oldfiles

local function initialize_oldfiles()
	oldfiles = require("libp.datatype.Lru")(1000)
	if vim.fn.filereadable(oldfiles_path) then
		for _, f in ipairs(vim.fn.readfile(oldfiles_path)) do
			oldfiles:add(f)
		end
	end
end

function M.setup()
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
			if not oldfiles then
				initialize_oldfiles()
			end
			oldfiles:add(arg.file)
		end,
	})
end

function M.oldfiles()
	if not oldfiles then
		initialize_oldfiles()
	end
	return oldfiles:values()
end

return M
