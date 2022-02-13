local M = {}

local Job = require("plenary.job")

local function remote_repository()
	return Job
		:new({
			command = "git",
			args = { "config", "--get", "remote.origin.url" },
		})
		:sync()
end

local function replace(str, what, with)
	what = string.gsub(what, "[%-]", "%%%1") -- escape pattern
	with = string.gsub(with, "[%%]", "%%%%") -- escape replacement
	return string.gsub(str, what, with)
end

function M.get_current_branch()
	local branchs = Job
		:new({
			command = "git",
			args = { "rev-parse", "--abbrev-ref", "HEAD" },
		})
		:sync()
	local current_branch_key = next(branchs)
	if current_branch_key == nil then
		error("failed to get current branch")
		return nil
	end
	return branchs[current_branch_key]
end

local function convert_git_repo_url_as_https(raw_remote_repo)
	if raw_remote_repo:find("https://github.com") == 1 then
		return raw_remote_repo
	elseif raw_remote_repo:find("git@github.com:") == 1 then
		local replaced = replace(raw_remote_repo, "^git@github.com:", "")
		replaced = replace(replaced, ".git$", "")
		return string.format("https://github.com/%s", replaced)
	else
		return nil
	end
end

function M.get_reomote_repository_url()
	local remote_repos = remote_repository()
	local remote_repo = next(remote_repos)
	if remote_repo == nil then
		error("remote repository not found")
		return nil
	end
	local conv_url = convert_git_repo_url_as_https(remote_repos[remote_repo])
	if conv_url == nil then
		error(string.format("not supported url:%s", remote_repos[remote_repo]))
		return nil
	end
	return conv_url
end

function M.get_git_root_path()
	local git_path = Job
		:new({
			command = "git",
			args = { "rev-parse", "--show-toplevel" },
		})
		:sync()
	local key = next(git_path)
	if key == nil then
		error("failed to git path")
		return nil
	end
	return git_path[key]
end

function M.convert_to_github_url(git_root_path, buffer_abs_path, repo_url, branch, start_row, end_row)
	local target_file_path = replace(buffer_abs_path, git_root_path, "")
	local dest_url
	if start_row == end_row then
		dest_url = string.format("%s/blob/%s%s#L%d", repo_url, branch, target_file_path, start_row)
	else
		dest_url = string.format("%s/blob/%s%s#L%d-L%d", repo_url, branch, target_file_path, start_row, end_row)
	end
	return dest_url
end

return M
