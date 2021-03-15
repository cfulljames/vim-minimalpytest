" Extremely simple, no-frills Pytest plugin.
"
" Just runs Pytest on the current [dir]ectory, [mod]ule, or [func]tion in a
" terminal window.
"
" Command syntax inspired by https://github.com/alfredodeza/pytest.vim.
"
" Usage:
"       :Mpt {object_type} [arg]
"
"       Where {object_type} is one of 'dir', 'mod', or 'func', and [arg] is an
"       optional list of arguments to pass to pytest.  Classes are not supported
"       at this time, but can still be run at the dir or mod levels.
"
" Configuration:
"       g:pytest_executable
"               The Pytest executable to use. (default: 'pytest')
"
"       g:convert_path_cmd
"               An external command (like 'wslpath -w' or 'cygpath -w') to use
"               to convert file paths. (default: none)

" Set Pytest executable
if !exists("g:pytest_executable")
    let g:pytest_executable = "pytest"
end

" Main entry point to the module
command! -nargs=+ Mpt call s:Mpt(<f-args>)

" Function version of the Mpt command.
" obj_type must be one of 'dir', 'mod', or 'func' and additional arguments will
" be passed directly to Pytest.
function! s:Mpt(obj_type, ...)
    if a:obj_type == "dir"
        " Get path of directory containing the current file
        let l:object = s:ConvertPath(expand('%:p:h:S'))
    elseif a:obj_type == "mod"
        " Get current file path
        let l:object = s:ConvertPath(expand('%:p:S'))
    elseif a:obj_type == "func"
        " Get current file path + function name (path::func)
        let l:mod = s:ConvertPath(expand('%:p:S'))
        let l:func = s:GetFuncName()
        if l:func == ""
            echoerr "No function found at cursor position"
            return
        endif
        let l:object = l:mod . '::' . l:func
    else
        echoerr "Invalid object type \""
            \ . a:obj_type
            \ . "\" Must be dir, mod, or func"
        return
    endif
    let l:term = s:GetTerminalBuffer()
    call s:RunPytest(l:term, l:object, a:000)
endfunction

" Use an external tool (like wslpath or cygpath) to convert file paths.
function! s:ConvertPath(path)
    if exists("g:convert_path_cmd")
        let l:path_lines = systemlist(g:convert_path_cmd . " " . a:path)
        return "'" . l:path_lines[0] . "'"
    endif
    return a:path
endfunction

" Get the name of the Python function under the cursor.
function! s:GetFuncName()
    let l:func_search = "^def"
    let l:line_num = search(l:func_search, "cbnW")

    let l:func_name = ""

    if l:line_num != 0
        let l:line = getline(l:line_num)
        let l:func_name_pattern = '\v^def\s+(\w+)\(.*\)'
        let l:func_match = matchlist(l:line, l:func_name_pattern)
        let l:func_name = l:func_match[1]
    endif

    return l:func_name
endfunction

" Get the buffer number of the terminal to use for Pytest.
function! s:GetTerminalBuffer()
    let l:terms = term_list()
    let l:num_terms = len(l:terms)
    if l:num_terms == 0
        terminal
        let l:terms = term_list()
    endif
    let l:term = l:terms[0]
    return l:term
endfunction

" Run Pytest in the given terminal with object (path/function) and arguments.
function! s:RunPytest(term, object, args)
    let l:cmd = g:pytest_executable . " " . join(a:args, " ") . " " . a:object
    call term_sendkeys(a:term, l:cmd . "\<cr>")
endfunction
