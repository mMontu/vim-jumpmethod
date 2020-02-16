" Source: https://stackoverflow.com/a/6855438/79125
" TODO:
" * Extract keywords for better language support.
"
" Modified by Robert Webb 17 Feb 2020 to fix various issues, see README.md

" Skip back over comment lines and blank lines
function! jumpmethod#SkipBackOverComments(current_line)
  let current_line = a:current_line
  while current_line > 1
    let text = getline(current_line)

    let pos = match(text, '\*/\s*$')
    if (pos >= 0)
      " End of a C-style comment, jump to other end
      call cursor(current_line, pos + 1)
      normal! %
      let current_line = line('.')
      let text = getline(current_line)
    endif

    " Skip back if start of C or C++ style comments and blank lines
    if (text =~ '^\s*\(//\|/\*\)' || text =~ '^\s*$')
      let current_line = current_line - 1
    else
      " Not a comment
      call cursor(current_line, 0)
      return
    endif
  endwhile
endfunction

" Uses keywords to determine which are curly braces are for methods.
function! jumpmethod#jump(char, flags, mode, includeClassesAndProperties)
  let original_cursor = getcurpos()

  if a:mode == 'v'
    normal! gv
  elseif a:mode == 'o'
    normal! v
  endif

  " Passing 'f' rather than '{' or '}' makes it jump to the function name
  " rather than the brace.  Handy when searching backwards and you can't see
  " what function you landed on because the '{' is at the top of the screen.
  " However the way I've implemented things it tends to scroll down to expose
  " the function name above anyway, so maybe not required.
  let char = a:char
  let goToFunctionName = 0
  if (char == 'f')
    let char = '{'
    let goToFunctionName = 1
  endif

  while search(char, a:flags) > 0
    let found = 0

    if char == '}'
      " jump to the opening one to analyze the definition
      normal! %
    endif

    " Remember where we are, with cursor on the '{'
    let openingBracePos = getcurpos()

    let current_line = line('.')
    let col = col('.')

    if getline(current_line) =~ '^\s*{'
      " it's alone on the line, check the line above
      let current_line = current_line - 1
    endif

    " Skip back over comment lines and blank lines
    call jumpmethod#SkipBackOverComments(current_line)

    let current_line = line('.')
    let text = getline(current_line)

    if (current_line == openingBracePos[1])
	" Still on original line, ignore everything after opening brace
	let text = strpart(text, 0, col - 1)
    endif

    " Strip trailing comment
    let text = substitute(text, '//.*', '', '')

    " See if there's a closing ')'
    let pos = match(text, ')\s*{\?\s*$')
    if (pos >= 0)

      " Found a closing ')', but function definition may span multiple lines,
      " so find matching '(' at start.
      call cursor(current_line, pos + 1)
      normal! %
      let current_line = line('.')

      let text = getline(current_line)

      if (text =~ '^\s*(')
        " Go back an extra line if '(' was on a new line
        " and skip back over comment lines and blank lines
        call jumpmethod#SkipBackOverComments(current_line - 1)

        let current_line = line('.')
        let text = getline(current_line)

        " Strip trailing comment
        let text = substitute(text, '//.*', '', '')
      else
        " Strip everything from the '(' on.  Note: cursor is currently on the '('
        let text = strpart(text, 0, col('.') - 1)
      endif

      if text =~ '\(\k\|>\)\s*$' &&
            \ text !~ '\<\(for\|foreach\|if\|while\|switch\|using\|catch\)\>\s*$'
        " it's probably a function call
        let found = 1

        " Scroll up to the function name so we can see it.
        exec 'normal! ' . current_line . 'G'
      endif

    elseif (a:includeClassesAndProperties)
      " No closing ')'.  Maybe worth stopping here anyway if it's a class
      " definition or property.
      if text !~ '\(\<\(else\|try\|finally\|get\|set\)\>\|=>\|;\|{\|}\)\s*{\?\s*$'
        " Probably something of interest
        let found = 1

        " Scroll up to the class/property name so we can see it.
        exec 'normal! ' . current_line . 'G'
      endif
    endif

    " If we found what we want, return
    if (found)
      if (goToFunctionName)
        normal! ^

        if (a:flags !~ 'b')
          " Make sure we didn't go backwards when we wanted to go forwards
          let newPos = getcurpos()
          if newPos[1] < original_cursor[1] ||
                \ (newPos[1] == original_cursor[1] && newPos[2] <= original_cursor[1])
            let found = 0
            normal! $
          endif
        endif
      else
        call setpos('.', openingBracePos)
        if char == '}'
          " we need to go back to the closing bracket
          normal! %
        endif
      endif

      if (found)
        call setpos("''", original_cursor)
        return
      endif
    endif

    call setpos('.', openingBracePos)
    if char == '}'
      " Go back to the closing bracket
      normal! %
    endif
  endwhile

  " if we're here, the search has failed, restore cursor position
  call setpos('.', original_cursor)
endfunction
