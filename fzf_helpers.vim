let g:ag_directories = ["$MYROOT"]

function! ExpandPath(key, value)
  return expand(a:value )
endfunction

function! MultiDirFzf(dirslist,namequery)
  let l:cmd = "find " . join(map(a:dirslist, function('ExpandPath')), " ") . " -type f -name " . "'" . a:namequery . "'"
  echom l:cmd 
  call fzf#run({'source': l:cmd,
        \'sink' : 'e', 'options': "+m ", "down" : "40%"  })
endfunction

command! -bang Mfzf call MultiDirFzf(g:ag_directories, "*.py")
