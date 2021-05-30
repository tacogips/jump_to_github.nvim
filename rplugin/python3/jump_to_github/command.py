import neovim
from neovim import Nvim
import os
import hashlib
from datetime import datetime
from typing import Union, Optional, Tuple
from git import Repo
import re

import webbrowser


class Browser:
    def __init__(self, open_cmd=None):
        self.open_cmd = open_cmd

    def open(self, url, with_http_server=False):
        # TODO(tacogips) windows uncompatible now
        if self.open_cmd:
            os.system(open_cmd + " " + url)
        else:
            webbrowser.open(url)

    def open_url(self, url: str):
        # TODO(tacogips) windows uncompatible now
        if self.open_cmd:
            os.system(open_cmd + " " + url)
        else:
            webbrowser.open(url)


def find_gits_root_path(dir_path: str) -> Optional[str]:
    try:
        if not os.path.exists(dir_path):
            return None

        if os.path.exists(os.path.join(dir_path, ".git")):
            return dir_path

        return find_gits_root_path(os.path.abspath(os.path.join(dir_path, "..")))
    except:
        return None


def remote_origin_path(dir_path: str) -> Optional[Tuple[str, str]]:
    repo = Repo.init(dir_path)
    origin = repo.remote(name="origin")
    if not origin:
        return None
    if not origin.urls:
        return None
    return list(origin.urls)[0], repo.active_branch.name


def git_origin_to_url(git_path: str) -> Optional[str]:
    matches = re.match("https://github.com/(.*?).git", git_path)
    if matches:
        if url := matches.group(1):
            return f"https://github.com/{url}"

    matches = re.match("git@github.com:(.*).git", git_path)
    if matches:
        if url := matches.group(1):
            return f"https://github.com/{url}"


def jump_dest_url(
    github_url: str,
    branch: str,
    relative_file_name: str,
    line: Union[tuple[int, int], int],
):
    line_fragment = ""
    if isinstance(line, tuple):
        start, end = line
        line_fragment = f"#L{start}-L{end}"
    else:
        line_fragment = f"#L{line}"

    return f"{github_url}/blob/{branch}/{relative_file_name}{line_fragment}"


@neovim.plugin
class JumpToGithub(object):
    def __init__(self, nvim: Nvim):
        self.nvim = nvim

    @neovim.command("JumpToGithub")
    def jump_to_github_plugin(self):

        file_path = self.file_path()
        if not file_path:
            return
        git_root_path = find_gits_root_path(os.path.dirname(file_path))
        if not git_root_path:
            self.nvim.command('echo "no .git folder found"')
            return
        origin_path_and_branch = remote_origin_path(git_root_path)
        if not origin_path_and_branch:
            self.nvim.command('echo "no git origin set"')
            return
        origin_path, branch = origin_path_and_branch

        git_base_url = git_origin_to_url(origin_path)
        if not git_base_url:
            self.nvim.command(f'echo "couldn\'t parse github url":{origin_path}')
            return

        relative_file_path = file_path.replace(git_root_path, "", 1)
        if relative_file_path[0] == "/":
            relative_file_path = str(relative_file_path[1:])

        dest_url = jump_dest_url(
            git_base_url, branch, relative_file_path, self.get_row()
        )

        browser = Browser(self.nvim.vars.get("jump_to_github_browser_cmd"))
        browser.open(dest_url)

    def file_path(self) -> str:
        return self.nvim.current.buffer.name

    def get_row(self) -> Union[tuple[int, int], int]:
        if rng := self.selected_rows():
            return rng
        else:
            return self.current_buffer_line()

    def selected_rows(self):
        buf = self.nvim.current.buffer
        (row1, col1) = buf.mark("<")
        (row2, col2) = buf.mark(">")
        if row1 == 0 and row2 == 0:
            return None
        return row1, row2

    def current_buffer_line(self):
        return self.nvim.current.window.cursor[0]
