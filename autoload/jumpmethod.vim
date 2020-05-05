" vim: et sw=2
"
" Original source: https://stackoverflow.com/a/6855438/79125
" TODO:
" * Extract keywords for better language support.

function! jumpmethod#PosCmp(posA, posB)
  if (a:posA[1] < a:posB[1])        " Compare line number
    return -1
  elseif (a:posA[1] > a:posB[1])    " Compare line number
    return 1
  elseif (a:posA[0] < a:posB[0])    " Compare column
    return -1
  elseif (a:posA[0] > a:posB[0])    " Compare column
    return 1
  endif
  return 0                          " Same position
endfunction

" Jump to the matching bracket.  Same as "%" but makes sure to keep the
" last-cursor mark.
function! jumpmethod#JumpToMatchingBracket()
  " Use "normal" rather than "normal!" to make use of improved mappings for "%".
  " keepjumps does all we need to retain jump marks, unless "%" has been mapped
  " to a better version, in which case it may still lose our marks, so
  " explicitly store and recall them.  We still use keepjumps though as it also
  " retains the whole old-jump list (accessed using Ctrl+O & Ctrl+I).
  " I don't know how to retain the whole jump list if "%" has been mapped.
  let lastCursorPos = getpos("''")
  keepjumps normal %
  call setpos("''", lastCursorPos)
endfunction

" Strip trailing comment
function! jumpmethod#StripTrailingComment(text)
  let text = a:text
  let pos = match(text, '/\*.*\*/')
  while (pos >= 0)
    let endPos = matchend(text, '\*/', pos + 2)

    " Remove the comment in such a way as to leave the string the same length
    let newText = strpart(text, 0, pos)
    let i = pos
    while (i < endPos)
      let newText = newText . ' '
      let i = i + 1
    endwhile
    let text = newText . strpart(text, endPos)

    " See if there's another comment to remove
    let pos = match(text, '/\*.*\*/', endPos)
  endwhile
  return substitute(text, '\(//\|/\*\).*', '', '')
endfunction

" Skip back over comment lines and blank lines
function! jumpmethod#SkipBackOverComments(current_line)
  let current_line = a:current_line
  while current_line > 1
    let text = getline(current_line)

    let pos = match(text, '\*/\s*$')
    if (pos >= 0)
      " End of a C-style comment, jump to other end
      call cursor(current_line, pos + 1)
      call jumpmethod#JumpToMatchingBracket()
      let current_line = line('.')
      let text = getline(current_line)
    endif

    " Skip back if start of C or C++ style comments and blank or # lines
    if (text =~ '^\s*\(//\|/\*\)' || text =~ '^\s*$' || text =~ '^\s*#')
      let current_line = current_line - 1
    else
      " Not a comment
      call cursor(current_line, 0)
      return
    endif
  endwhile
endfunction

" Return the given string with any matches of pattern blanked out, ie turned
" into the same number of spaces
function! jumpmethod#BlankOut(string, pattern)
  let string = a:string
  while (1)
    let start = match(string, a:pattern)
    let end = matchend(string, a:pattern)
    if (start < 0 || end < 0)
      return string
    endif

    let string = strpart(string, 0, start)
    let i = start
    while (i < end)
      let string = string . ' '
      let i = i + 1
    endwhile
    let string = string . strpart(a:string, end)
  endwhile
  return string
endfunction

" Uses keywords to determine which are curly braces are for methods.
function! jumpmethod#jump(char, flags, mode, includeClassesAndProperties)
  normal! m'
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
      call jumpmethod#JumpToMatchingBracket()
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
    let text = jumpmethod#StripTrailingComment(text)

    " See if there's a closing ')'
    let pos = match(text, ')\s*{\?\s*$')
    if (pos >= 0)

      " Found a closing ')', but function definition may span multiple lines,
      " so find matching '(' at start.
      call cursor(current_line, pos + 1)
      call jumpmethod#JumpToMatchingBracket()
      let current_line = line('.')

      let text = getline(current_line)

      if (text =~ '^\s*(')
        " Go back an extra line if '(' was on a new line
        " and skip back over comment lines and blank lines
        call jumpmethod#SkipBackOverComments(current_line - 1)

        let current_line = line('.')
        let text = getline(current_line)

        " Strip trailing comment
        let text = jumpmethod#StripTrailingComment(text)
      else
        " Strip everything from the '(' on.  Note: cursor is currently on the '('
        let text = strpart(text, 0, col('.') - 1)
      endif

      if text =~ '\(\k\|>\)\s*$' &&
            \ text !~ '\<\(for\|foreach\|if\|while\|switch\|using\|catch\)\>\s*$' &&
            \ text !~ '[=(,]\s*new'
        " it's probably a function call
        let found = 1

        " Scroll up to the function name so we can see it.
        exec 'keepjumps normal! ' . current_line . 'G'
      endif

    elseif (a:includeClassesAndProperties)
      " No closing ')'.  Maybe worth stopping here anyway if it's a class
      " definition or property.
      if text !~ '\(\<\(else\|do\|try\|finally\|get\|set\)\>\|:\|=\|=>\|;\|{\|}\)\s*{\?\s*$' &&
            \ text !~ '[=(,]\s*new'
        " Probably something of interest
        let found = 1

        " Scroll up to the class/property name so we can see it.
        exec 'keepjumps normal! ' . current_line . 'G'
      endif
    endif

    " If we found what we want, return
    if (found)
      if (goToFunctionName)
        keepjumps normal! ^

        if (a:flags !~ 'b')
          " Make sure we didn't go backwards when we wanted to go forwards
          let newPos = getcurpos()
          if (jumpmethod#PosCmp(newPos, original_cursor) <= 0)
            let found = 0
            keepjumps normal! $
          endif
        endif
      else
        call setpos('.', openingBracePos)
        if char == '}'
          " We need to go back to the closing bracket
          call jumpmethod#JumpToMatchingBracket()
        endif
      endif

      if (found)
        return
      endif
    endif

    call setpos('.', openingBracePos)
    if char == '}'
      " Go back to the closing bracket
      call jumpmethod#JumpToMatchingBracket()
    endif
  endwhile

  " if we're here, the search has failed, restore cursor position
  call setpos('.', original_cursor)
endfunction

" Jump back to declaraction of identifier under cursor
function! jumpmethod#gd(fromStartOfFile)
  normal! m'
  let winSave = winsaveview()
  let origPos = getcurpos()
  let word = expand('<cword>')
  if (word == "")
    " Don't use echoerr as it will scroll the screen annoyingly
    echohl ErrorMsg
    echo 'No identifier under cursor'
    echohl None

    " Beep
    exec "normal! \<Esc>"
    return
  endif

  if (!a:fromStartOfFile)
    call jumpmethod#jump('f', 'Wb', 'n', 0)
  endif
  let newPos = getcurpos()
  if (newPos == origPos)
    0
  endif

  let word = '\<' . word . '\>'
  while (search(word, 'W') > 0)
    let newPos = getcurpos()
    if (jumpmethod#PosCmp(newPos, origPos) >= 0)
      break
    endif

    let line = line('.')
    let text = getline(line)

    " Strip trailing comment
    let text = jumpmethod#StripTrailingComment(text)

    " Ignore lines that appear to be comments
    if text =~ '^\s*\(/\*\|\*\)'
      continue
    endif

    " Ignore anything in strings.
    let text = jumpmethod#BlankOut(text, '"[^"]*"')

    " Ignore matches referenced as members of other classes
    let text = jumpmethod#BlankOut(text, '\(\.\|->\|::\)\s*' . word)

    " See if it still matches
    let column = match(text, word)
    if (column >= 0)
      " Yep, still matches, we've found our answer.
      " In case there were also bad matches on the same line,
      " make sure we have the right column.
      if (column > 0)
        exec 'keepjumps normal! 0' . column . 'l'
      endif

      " Finally, check that we're not in a {..} block that ended before the
      " cursor.  Jump forward to the closing '}' and see where we land.
      let foundPos = getcurpos()
      keepjumps normal! ]}
      let newPos = getcurpos()
      if (jumpmethod#PosCmp(newPos, origPos) <= 0)
        continue        " Scope ended already
      endif

      " Restore the window so that other intermediate jumps don't mess up our
      " scrolling
      call winrestview(winSave)

      call setpos('.', foundPos)

      " Success
      return
    endif
  endwhile

  " Not found, go back to where we started.
  call winrestview(winSave)

  " Don't use echoerr as it will scroll the screen annoyingly
  echohl ErrorMsg
  echo 'No declaration found'
  echohl None

  " Beep
  exec "normal! \<Esc>"
endfunction
