let s:server = expand('<sfile>:p:h:h:h') . '/pythonx/aiocomplete_jedi.py'

let aiocomplete#completors#jedi#jedi = {
            \ 'invoke_pattern': '\k\.\?$\|import $',
            \ 'priority': 0,
            \ 'include': ['python'],
            \ 'exclude': []
            \ }

func! aiocomplete#completors#jedi#jedi.init(config) abort
    call extend(self, a:config)
    call s:init_jedi()
endfunc

func! aiocomplete#completors#jedi#jedi.complete(ctx, callback) abort
    if a:ctx['typed'] =~ self.invoke_pattern
        let l:ctx = {
            \ 'src': join(getline(1, '$'), "\n"),
            \ 'line': a:ctx['lnum'],
            \ 'col': a:ctx['col'] - 1, 
            \ 'path': a:ctx['path']
        \ }
        call s:ensure_channel_open(self)
        call ch_sendexpr(self.channel, l:ctx, {
                    \ 'callback': function('s:complete_handler', [a:ctx, a:callback])
                    \})
    endif
endfunc

func! s:ensure_channel_open(completor) abort
    if !has_key(a:completor, 'channel') || ch_status(a:completor.channel) != 'open'
        let a:completor.channel = ch_open('127.0.0.1:8888')
    endif
endfunc

func! s:complete_handler(ctx, callback, channel, msg) abort
    let l:completions = []
    for l:comp in a:msg
        call add(l:completions, {'abbr': l:comp['name'], 'word': l:comp['tail'], 'menu': l:comp['desc']})
    endfor
    call a:callback(a:ctx, a:ctx['col'], l:completions)
endfunc

func! s:init_jedi()
    let s:job = job_start('python ' . s:server)
endfunc
