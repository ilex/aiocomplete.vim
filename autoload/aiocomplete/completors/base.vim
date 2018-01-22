func! s:complete(ctx, callback) dict abort
endfunc

func! s:should_invoke(ctx) dict abort
    return a:ctx['typed'] =~ self.invoke_pattern
endfunc

func! s:invoke_complete(ctx, callback) dict abort
    if self.should_invoke(a:ctx)
        call self.complete(a:ctx, a:callback)
    endif
endfunc

func aiocomplete#completors#base#build(config) abort
    let l:res = extend({
            \ 'invoke_pattern': '\k$',
            \ 'priority': 0,
            \ 'include': ['*'],
            \ 'exclude': []
            \ }, a:config)

    let l:res.should_invoke = function('s:should_invoke')
    let l:res.complete = function('s:complete')
    let l:res.invoke_complete = function('s:invoke_complete')

    return l:res
endfunc
