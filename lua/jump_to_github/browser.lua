_BrowserConfig = {}
local M = {}
M.config = _BrowserConfig

local Job = require("plenary.job")

function M.open(url)
	return Job
		:new({
			command = M.config.open_cmd,
			args = { url },
		})
		:sync()
end

return M
