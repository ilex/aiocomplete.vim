let s:words = {}
let s:last_word = ''

let aiocomplete#completors#buffer#buffer = {
            \ 'invoke_pattern': '\k$',
            \ 'priority': 0,
            \ 'include': ['*'],
            \ 'exclude': []
            \ }

func! aiocomplete#completors#buffer#buffer.init(config) abort
    call extend(self, a:config)
endfunc

func! aiocomplete#completors#buffer#buffer.complete(ctx, callback) abort
    if a:ctx['typed'] =~ self.invoke_pattern
        let [l:startcol, l:words] = s:complete(a:ctx)
        call a:callback(a:ctx, l:startcol, l:words)
    endif
endfunc

func! s:complete(ctx) abort
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
                        \})
        endif
    endfor
    return [l:col, l:matches]
endfunc

function! s:refresh_keywords() abort
    let l:text = join(getline(1, '$'), "\n")
    for l:word in split(l:text, '\W\+')
        if len(l:word) > 1
            let s:words[l:word] = 1
        endif
    endfor
endfunction

func! s:map_completions(key, val) abort
    return {"word":v:val,"dup":1,"icase":1,"menu": "[buffer]"}
endfunc
