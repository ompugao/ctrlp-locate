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

let g:ctrlp_locate_input_pattern = ""

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
  let g:ctrlp_locate_input_pattern = keyinput
  call ctrlp#init(ctrlp#locate#id())
endfunction

function! ctrlp#locate#init(...)
  nnoremap <buffer> <c-d> :call <SID>trigger_locate()<cr>
  if !executable("locate")
    echo 'locate command is not on your path.'
    call ctrlp#exit()
    return
  endif
  "call ctrlp#init(ctrlp#locate#id())
  let input_pattern = get(g:,'ctrlp_locate_input_pattern','')
  if input_pattern == ""
    return []
  endif
  let cmd = 'locate'
  if g:ctrlp_locate_max_candidates != 0
    let cmd .= ' -l ' . g:ctrlp_locate_max_candidates
  endif
  let cmd .= ' -w -r "' . substitute(input_pattern," ", ".*", "g") . '"'
  if input_pattern[0] != '.'
    let cmd .= ' | egrep -v "/\.+" ' "omit directories whose name starts with dot
  endif
  echomsg 'wait a moment...: [cmd: ' . cmd . ']'
  let paths = split(system(cmd),"\n")
  return paths
endfunc

function! ctrlp#locate#accept(mode, str)
  call ctrlp#exit()
  call ctrlp#acceptfile(a:mode, a:str)
endfunction

function! ctrlp#locate#exit()
  unlet! g:ctrlp_locate_input_pattern
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#locate#id()
  return s:id
endfunction
