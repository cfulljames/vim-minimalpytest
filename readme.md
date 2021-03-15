Minimal Pytest Plugin for Vim
=============================

Extremely simple, no-frills Pytest plugin for Vim 8+.

Just provides a handy command to run Pytest on the current [dir]ectory,
[mod]ule, or [func]tion in a terminal window.

Command syntax inspired by [pytest.vim](https://github.com/alfredodeza/pytest.vim).

Usage:
------

```
:Mpt {object_type} [arg]
```

Where `{object_type}` is one of "dir", "mod", or "func", and `[arg]` is an
optional list of arguments to pass to pytest.  Classes are not supported at this
time, but can still be run at the dir or mod levels.

Configuration:
--------------

- `g:pytest_executable`: The Pytest executable to use. (default: "pytest")
- `g:convert_path_cmd`: An external command (like "wslpath -w" or "cygpath -w")
  to use to convert file paths. (default: none)
