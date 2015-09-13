if exists('g:loaded_ctrlp_locate') && g:loaded_ctrlp_locate
  finish
endif
let g:loaded_ctrlp_locate = 1

let s:V = vital#of('ctrlp_locate')
let s:Prelude = s:V.import('Prelude')
let s:DataString = s:V.import('Data.String')
let s:Process = s:V.import('Process')

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

let g:ctrlp_locate_max_candidates = get(g:, 'ctrlp_locate_max_candidates', 0)
let g:ctrlp_locate_lazy_update = get(g:, 'ctrlp_locate_lazy_update', 500)
let g:ctrlp_locate_min_chars = get(g:, 'ctrlp_locate_min_chars', 5)

" quoted from [unite-locate](https://github.com/ujihisa/unite-locate)
" If the locate command is linux version, use -e option which means fetching
" only existing files.
function! s:is_linux()
  " Linux version only has -V option
  call s:Process.system('locate -V')
  return !s:Process.get_last_status()
endfunction

function! s:generate_locate_command(input_query, ...)
  let cmd = ''
  let query = a:input_query
  let limit_num_result = g:ctrlp_locate_max_candidates!=0

  if has_key(g:, 'ctrlp_locate_command_definition')
    let cmd = g:ctrlp_locate_command_definition
  elseif s:Prelude.is_mac()
    let cmd = 'mdfind -name "{query}"' . (limit_num_result? ' | head -n {max_candidates}': '')
  elseif executable('locate')
    let cmd = 'locate -w' 
          \ . (limit_num_result? ' -l {max_candidates}' : '')
          \ . (s:is_linux() ? ' -e' : '')
          \ . ' -r "{query}"'
    let query = s:DataString.replace(a:input_query," ", ".*")
  elseif executable('es')
    let cmd = 'es -i -r'
          \ . (limit_num_result ? ' -n {max_candidates}' : '')
          \ . ' {query}'
  endif

  let cmd = s:DataString.replace(cmd,'{query}', query)
  let cmd = s:DataString.replace(cmd,'{max_candidates}', g:ctrlp_locate_max_candidates)
  return cmd
endfunction

function! ctrlp#locate#start()
  let s:old_matcher = get(g:, 'ctrlp_match_func', 0)
  let g:ctrlp_match_func = {'match': 'ctrlp#locate#matcher'}
  let s:old_lazy_update = get(g:, 'ctrlp_lazy_update', 0) 
  if g:ctrlp_locate_lazy_update == 0
    echom "[Warn]ctrlp-locate: Do not set g:ctrlp_locate_lazy_update to 0!"
    let g:ctrlp_locate_lazy_update = 1
  endif
  let g:ctrlp_lazy_update = g:ctrlp_locate_lazy_update
  call ctrlp#init(ctrlp#locate#id())
endfunction

function! ctrlp#locate#init(...)
  return []
endfunction

function! ctrlp#locate#matcher(items, input, limit, mmode, ispath, crfile, regex)
  if len(a:input) <= g:ctrlp_locate_min_chars
    return []
  endif
  let cmd = s:generate_locate_command(a:input, a:regex)
  let paths = split(s:Process.system(cmd),"\n")
  return paths
endfunction

function! ctrlp#locate#accept(mode, str)
  call ctrlp#exit()
  call ctrlp#acceptfile(a:mode, a:str)
endfunction

function! ctrlp#locate#exit()
  call s:revert_settings()
endfunction

function! s:revert_settings()
  if type(s:old_matcher) == 0
    unlet! g:ctrlp_match_func
  else
    let g:ctrlp_match_func = s:old_matcher
  endif
  let g:ctrlp_lazy_update = s:old_lazy_update
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#locate#id()
  return s:id
endfunction
