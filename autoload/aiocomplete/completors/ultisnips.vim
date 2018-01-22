func aiocomplete#completors#ultisnips#build(config) abort
    let l:res = aiocomplete#completors#base#build(a:config)

    let l:res.complete = function('s:complete')
    return l:res
endfunc

func! s:complete(ctx, callback) dict abort
    let l:col = a:ctx['col']
    let l:snips = UltiSnips#SnippetsInCurrentScope()

    if !l:snips
        return 
    endif

    let l:typed = a:ctx['typed']

    let l:kw = matchstr(l:typed, '\v\S+$')
    let kwlen = len(l:kw)

    if kwlen < 1
        return 
    endif

    let l:matches = []

    for l:word in l:snips
        if l:word =~ '^' . l:kw
            call add(l:matches, {
                        \ 'abbr': l:word,
                        \ 'word': l:word[kwlen:],
                        \ 'menu': '[ultisnips]'
                        \})
        endif
    endfor
    call a:callback(a:ctx, l:col, l:matches)
endfunc
