local M = {}

local api = vim.api
local fn = vim.fn

function M.get_current_row()
	return fn.getpos(".")[2]
end

function M.get_current_buffer_abspath()
	return api.nvim_buf_get_name(0)
end

return M
