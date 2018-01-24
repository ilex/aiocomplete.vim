let s:words = {}

func aiocomplete#completors#buffer#build(config) abort
    let l:res = aiocomplete#completors#base#build(a:config)

    let l:res.complete = function('s:complete')
    return l:res
endfunc

func! s:complete(ctx, callback) dict abort
    call s:refresh_keywords()

    let l:matches = []
    let l:col = a:ctx['col']

    if empty(s:words)
        return [l:col, []]
    endif
    
    let l:typed = a:ctx['typed']

    let l:kw = matchstr(l:typed, '\w\+$')
    let l:kwlen = len(l:kw)

    if l:kwlen < 1
        return [l:col, []]
    endif

    let l:words = keys(s:words)
    
    for l:word in l:words
        if l:word =~ '^' . l:kw
            call add(l:matches, {
                        \ 'abbr': l:word,
                        \ 'word': l:word[l:kwlen:],
                        \ 'menu': '[buffer]',
                        \ 'kind': 'v'
                        \})
        endif
    endfor
    call a:callback(a:ctx, l:col, l:matches)
endfunc

function! s:refresh_keywords() abort
    let l:text = join(getline(1, '$'), "\n")
    for l:word in split(l:text, '\W\+')
        if len(l:word) > 1
            let s:words[l:word] = 1
        endif
    endfor
endfunction
