"command! -nargs=? CtrlPLocate call ctrlp#locate#init(<q-args>)
"
command! CtrlPLocate call ctrlp#init(ctrlp#locate#id())
