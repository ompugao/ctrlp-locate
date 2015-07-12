if exists('g:loaded_ctrlp_locate') && g:loaded_ctrlp_locate
  finish
endif
let g:loaded_ctrlp_locate = 1

let s:locate_var = {
\ 'init'   : 'ctrlp#locate#init()',
\ 'exit'   : 'ctrlp#locate#exit()',
\ 'accept' : 'ctrlp#locate#accept',
\ 'lname'  : 'locate',
\ 'sname'  : 'locate',
\ 'type'   : 'line',
\ 'sort'   : 0,
\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:locate_var)
else
  let g:ctrlp_ext_vars = [s:locate_var]
endif

function! s:set_global_variable(key, default)
  if !has_key(g:, a:key)
    let g:[a:key] = a:default
  endif
endfunction

call s:set_global_variable('ctrlp_locate_max_candidates', 0)

let s:ctrlp_locate_input_query = ""

" quoted from:
" Big Sky :: vimでスクリプト内関数を書き換える http://mattn.kaoriya.net/software/vim/20090826003359.htm
function! s:GetScriptID(fname)
  let snlist = ''
  redir => snlist
  silent! scriptnames
  redir END
  let smap = {}
  let mx = '^\s*\(\d\+\):\s*\(.*\)$'
  for line in split(snlist, "\n")
    let smap[fnamemodify(tolower(substitute(line, mx, '\2', '')), ":p:t")] = substitute(line, mx, '\1', '')
  endfor
  return smap[tolower(a:fname)]
endfunction

function! s:GetFunc(fname, funcname)
  let sid = s:GetScriptID(a:fname)
  return function("<SNR>".sid."_".a:funcname)
endfunction

function! s:trigger_locate()
  let CtrlPGetInput = s:GetFunc('ctrlp.vim', 'getinput')
  let keyinput = CtrlPGetInput()
  call ctrlp#exit()
  redraw
  let s:ctrlp_locate_input_query = keyinput
  call ctrlp#init(ctrlp#locate#id())
endfunction

" quoted from [unite-locate](https://github.com/ujihisa/unite-locate)
" If the locate command is linux version, use -e option which means fetching
" only existing files.
function! s:is_linux()
  " Linux version only has -V option
  call system('locate -V')
  return !v:shell_error
endfunction

function! s:locate_command(input_query)
  let locate_command = ''
  if has('mac')
    let locate_command = 'mdfind -name "' . a:input_query . '"'
          \ . (g:ctrlp_locate_max_candidates!=0 ? ' | head -n ' . g:ctrlp_locate_max_candidates : '')
  elseif executable('locate')
    let input_query_regex = substitute(a:input_query," ", ".*", "g")
    let locate_command = 'locate -w'
          \ . (g:ctrlp_locate_max_candidates!=0 ? ' -l '.g:ctrlp_locate_max_candidates : '')
          \ . (s:is_linux() ? ' -e' : ''). ' -r "' . input_query_regex . '"'
          \ . (a:input_query[0]!='.' ? ' | egrep -v "/\.+" ' : '') "omit directories whose name starts with dot
  elseif executable('es')
    let locate_command = 'es -i -r'
          \ . (g:ctrlp_locate_max_candidates!=0 ? ' -n '.g:ctrlp_locate_max_candidates : '')
          \ . ' ' . a:input_query
  endif
  return locate_command
endfunction

function! ctrlp#locate#init(...)
  nnoremap <buffer> <c-d> :call <SID>trigger_locate()<cr>
  "call ctrlp#init(ctrlp#locate#id())
  let input_query = get(s:,'ctrlp_locate_input_query','')
  if input_query == ""
    return []
  endif
  let cmd = s:locate_command(input_query)
  if cmd==""
    echo 'Sorry, I cannot generate any command.'
    call ctrlp#exit()
    return
  endif
  echomsg 'wait a moment...: [cmd: ' . cmd . ']'
  let paths = split(system(cmd),"\n")
  return paths
endfunction

function! ctrlp#locate#accept(mode, str)
  call ctrlp#exit()
  call ctrlp#acceptfile(a:mode, a:str)
endfunction

function! ctrlp#locate#exit()
  unlet! s:ctrlp_locate_input_query
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#locate#id()
  return s:id
endfunction
