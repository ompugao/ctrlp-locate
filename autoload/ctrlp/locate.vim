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
\ 'type'   : 'path',
\ 'sort'   : 0,
\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:locate_var)
else
  let g:ctrlp_ext_vars = [s:locate_var]
endif

function! ctrlp#locate#init()
  if !executable("locate")
    echo 'locate command is not installed.'
    ctrlp#locate#exit()
    return
  endif
  let ans = input('search: ')
  let pwd = getcwd()
  let cmd = 'locate -w -r "' . pwd . '.*' . substitute(ans ," ", ".*", "g") . '"'
  if ans[0] != '.'
    let cmd .= ' | egrep -v "/\.+" ' "omit directories name of which starts with dot
  endif
  echo ' '
  echomsg 'wait a moment...: [cmd: ' . cmd . ']'
  let pathes = split(system(cmd),"\n")
  return pathes
endfunc

function! ctrlp#locate#accept(mode, str)
  call ctrlp#acceptfile(a:mode, a:str)
endfunction

function! ctrlp#locate#exit()
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#locate#id()
  return s:id
endfunction
