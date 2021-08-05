" Source: https://stackoverflow.com/a/6855438/79125
"
" Modified by Robert Webb 17 Feb 2020 to add [[ and ]] mappings, see README.md

function! jumpmethod#plug#setup_plug()
    nnoremap <Plug>(jumpmethod-section-tostart-fwd)  :<c-u>call jumpmethod#jump('{', 'W',  'n', 1)<cr>
    nnoremap <Plug>(jumpmethod-section-tostart-back) :<c-u>call jumpmethod#jump('{', 'Wb', 'n', 1)<cr>
    nnoremap <Plug>(jumpmethod-section-toend-fwd)    :<c-u>call jumpmethod#jump('}', 'W',  'n', 1)<cr>
    nnoremap <Plug>(jumpmethod-section-toend-back)   :<c-u>call jumpmethod#jump('}', 'Wb', 'n', 1)<cr>
    nnoremap <Plug>(jumpmethod-curly-tostart-fwd)   :<c-u>call jumpmethod#jump('{', 'W',  'n', 0)<cr>
    nnoremap <Plug>(jumpmethod-curly-tostart-back)  :<c-u>call jumpmethod#jump('{', 'Wb', 'n', 0)<cr>
    nnoremap <Plug>(jumpmethod-curly-toend-fwd)     :<c-u>call jumpmethod#jump('}', 'W',  'n', 0)<cr>
    nnoremap <Plug>(jumpmethod-curly-toend-back)    :<c-u>call jumpmethod#jump('}', 'Wb', 'n', 0)<cr>

    xnoremap <Plug>(jumpmethod-section-tostart-fwd)  :<c-u>call jumpmethod#jump('{', 'W',  'v', 1)<cr>
    xnoremap <Plug>(jumpmethod-section-tostart-back) :<c-u>call jumpmethod#jump('{', 'Wb', 'v', 1)<cr>
    xnoremap <Plug>(jumpmethod-section-toend-fwd)    :<c-u>call jumpmethod#jump('}', 'W',  'v', 1)<cr>
    xnoremap <Plug>(jumpmethod-section-toend-back)   :<c-u>call jumpmethod#jump('}', 'Wb', 'v', 1)<cr>
    xnoremap <Plug>(jumpmethod-curly-tostart-fwd)   :<c-u>call jumpmethod#jump('{', 'W',  'v', 0)<cr>
    xnoremap <Plug>(jumpmethod-curly-tostart-back)  :<c-u>call jumpmethod#jump('{', 'Wb', 'v', 0)<cr>
    xnoremap <Plug>(jumpmethod-curly-toend-fwd)     :<c-u>call jumpmethod#jump('}', 'W',  'v', 0)<cr>
    xnoremap <Plug>(jumpmethod-curly-toend-back)    :<c-u>call jumpmethod#jump('}', 'Wb', 'v', 0)<cr>

    onoremap <Plug>(jumpmethod-section-tostart-fwd)  :<c-u>call jumpmethod#jump('{', 'W',  'o', 1)<cr>
    onoremap <Plug>(jumpmethod-section-tostart-back) :<c-u>call jumpmethod#jump('{', 'Wb', 'o', 1)<cr>
    onoremap <Plug>(jumpmethod-section-toend-fwd)    :<c-u>call jumpmethod#jump('}', 'W',  'o', 1)<cr>
    onoremap <Plug>(jumpmethod-section-toend-back)   :<c-u>call jumpmethod#jump('}', 'Wb', 'o', 1)<cr>
    onoremap <Plug>(jumpmethod-curly-tostart-fwd)   :<c-u>call jumpmethod#jump('{', 'W',  'o', 0)<cr>
    onoremap <Plug>(jumpmethod-curly-tostart-back)  :<c-u>call jumpmethod#jump('{', 'Wb', 'o', 0)<cr>
    onoremap <Plug>(jumpmethod-curly-toend-fwd)     :<c-u>call jumpmethod#jump('}', 'W',  'o', 0)<cr>
    onoremap <Plug>(jumpmethod-curly-toend-back)    :<c-u>call jumpmethod#jump('}', 'Wb', 'o', 0)<cr>

    noremap <Plug>(jumpmethod-gd)  :<c-u>call jumpmethod#gd(0)<cr>
    noremap <Plug>(jumpmethod-gD)  :<c-u>call jumpmethod#gd(1)<cr>

    let s:setup_plug = 1
endf

function! jumpmethod#plug#map_to_plug_in_buffer()
    if !exists("s:setup_plug") || s:setup_plug == 0
        call jumpmethod#plug#setup_plug()
    endif

    nmap <buffer> ]] <Plug>(jumpmethod-section-tostart-fwd)
    nmap <buffer> [[ <Plug>(jumpmethod-section-tostart-back)
    nmap <buffer> ][ <Plug>(jumpmethod-section-toend-fwd)
    nmap <buffer> [] <Plug>(jumpmethod-section-toend-back)
    nmap <buffer> ]m <Plug>(jumpmethod-curly-tostart-fwd)
    nmap <buffer> [m <Plug>(jumpmethod-curly-tostart-back)
    nmap <buffer> ]M <Plug>(jumpmethod-curly-toend-fwd)
    nmap <buffer> [M <Plug>(jumpmethod-curly-toend-back)

    xmap <buffer> ]] <Plug>(jumpmethod-section-tostart-fwd)
    xmap <buffer> [[ <Plug>(jumpmethod-section-tostart-back)
    xmap <buffer> ][ <Plug>(jumpmethod-section-toend-fwd)
    xmap <buffer> [] <Plug>(jumpmethod-section-toend-back)
    xmap <buffer> ]m <Plug>(jumpmethod-curly-tostart-fwd)
    xmap <buffer> [m <Plug>(jumpmethod-curly-tostart-back)
    xmap <buffer> ]M <Plug>(jumpmethod-curly-toend-fwd)
    xmap <buffer> [M <Plug>(jumpmethod-curly-toend-back)

    omap <buffer> ]] <Plug>(jumpmethod-section-tostart-fwd)
    omap <buffer> [[ <Plug>(jumpmethod-section-tostart-back)
    omap <buffer> ][ <Plug>(jumpmethod-section-toend-fwd)
    omap <buffer> [] <Plug>(jumpmethod-section-toend-back)
    omap <buffer> ]m <Plug>(jumpmethod-curly-tostart-fwd)
    omap <buffer> [m <Plug>(jumpmethod-curly-tostart-back)
    omap <buffer> ]M <Plug>(jumpmethod-curly-toend-fwd)
    omap <buffer> [M <Plug>(jumpmethod-curly-toend-back)

    map <buffer> gd <Plug>(jumpmethod-gd)
    map <buffer> gD <Plug>(jumpmethod-gD)
endf


" Options 
if !exists("g:jumpmethod_default_percent")
   let g:jumpmethod_default_percent = 0
endif
