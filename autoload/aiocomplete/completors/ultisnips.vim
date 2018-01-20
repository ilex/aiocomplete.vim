let aiocomplete#completors#ultisnips#ultisnips = {
            \ 'invoke_pattern': '\k$',
            \ 'priority': 0,
            \ 'include': ['*'],
            \ 'exclude': []
            \ }

func! aiocomplete#completors#ultisnips#ultisnips.init(config) abort
    call extend(self, config)
endfunc

func! aiocomplete#completors#ultisnips#ultisnips.complete(ctx, callback) abort
    if a:ctx['typed'] =~ self.invoke_pattern
        let [l:startcol, l:words] = s:complete(a:ctx)
        call a:callback(a:ctx, l:startcol, l:words)
    endif
endfunc

func! s:complete(ctx) abort
    let l:col = a:ctx['col']
    let l:snips = UltiSnips#SnippetsInCurrentScope()

    if !l:snips
        return [l:col, []]
    endif

    let l:typed = a:ctx['typed']

    let l:kw = matchstr(l:typed, '\v\S+$')
    let kwlen = len(l:kw)

    if kwlen < 1
        return [l:col, []] 
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
    return [l:col, l:matches]
endfunc
