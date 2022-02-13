local M = {}

local cmd = vim.cmd
local git = require("jump_to_github.git")
local buffer = require("jump_to_github.buffer")
local browser = require("jump_to_github.browser")

function M.setup(opt)
	browser.config.open_cmd = opt.open_cmd or "brave"

	cmd(
		[[command! -range JumpToGithub :<line1>,<line2>lua require("jump_to_github").jump_current_lines(<line1>,<line2>)]]
	)
end

function M.jump_current_lines(range_start_row, range_end_row)
	local start_row, end_row
	if range_start_row == nil or range_end_row == nil then
		local row = buffer.get_current_row()
		start_row, end_row = row, row
	else
		start_row, end_row = range_start_row, range_end_row
	end

	local remote_repo_url = git.get_reomote_repository_url()
	local current_branch = git.get_current_branch()

	local git_root_path = git.get_git_root_path()
	local buffer_abspath = buffer.get_current_buffer_abspath()
	local dest_url = git.convert_to_github_url(
		git_root_path,
		buffer_abspath,
		remote_repo_url,
		current_branch,
		start_row,
		end_row
	)

	browser.open(dest_url)
end

return M
