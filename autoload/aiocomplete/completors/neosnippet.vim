func aiocomplete#completors#neosnippet#build(config) abort
    let l:res = aiocomplete#completors#base#build(a:config)

    let l:res.complete = function('s:complete')
    return l:res
endfunc

func! s:complete(ctx, callback) dict abort
    let l:col = a:ctx['col']

    let l:snips = values(neosnippet#helpers#get_completion_snippets())

    if empty(l:snips)
        return 
    endif

    let l:typed = a:ctx['typed']

    let l:kw = matchstr(l:typed, '\v\S+$')
    let kwlen = len(l:kw)

    if kwlen < 1
        return 
    endif

    let l:matches = []

    for l:item in l:snips
        if l:item['word'] =~ '^' . l:kw
            call add(l:matches, {
                        \ 'abbr': l:item['word'],
                        \ 'word': l:item['word'][kwlen:],
                        \ 'menu': 'snip: ' . l:item['menu_abbr'],
                        \ 'kind': 'd',
                        \})
        endif
    endfor
    call a:callback(a:ctx, l:col, l:matches)
endfunc
