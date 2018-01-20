let g:aiocomplete_debounce_delay = 200
let s:completors = {} 
let s:completions = {}

let s:builtin_completors = {
            \ 'buffer': aiocomplete#completors#buffer#buffer,
            \ 'jedi': aiocomplete#completors#jedi#jedi,
            \ 'ultisnips': aiocomplete#completors#ultisnips#ultisnips,
            \ }

func! aiocomplete#init(config)
    for [l:name, l:config] in items(a:config['completors'])
        call s:register_completor(l:name, l:config) 
    endfor
endfunc

func! s:register_completor(name, config)
    if has_key(s:builtin_completors, a:name)
        let s:completors[a:name] = s:builtin_completors[a:name]
        call s:completors[a:name].init(a:config)
    endif
    " TODO: add external completor
    call s:register_events()
endfunc

func! s:register_events()
    augroup aiocomplete
        autocmd!
        autocmd FileType * call s:init_buffer_completors() 
    augroup END
endfunc

func! s:init_buffer_completors()
    let b:aiocompletors = {} 
    for [l:name, l:completor] in items(s:completors)
        let l:continue = 0
        for l:type in l:completor.exclude
            if l:type == '*' || l:type == &filetype
                let l:continue = 1
                break
            endif
        endfor
        if l:continue
            continue
        endif
        for l:type in l:completor.include
            if l:type == '*' || l:type == &filetype
                let b:aiocompletors[l:name] = l:completor
                break
            endif
        endfor
    endfor
    if !empty(b:aiocompletors)
        call s:register_buffer_events()
    endif
endfunc

func! s:register_buffer_events()
    augroup aiocomplete_buffer
        autocmd! * <buffer>
        autocmd TextChangedI <buffer> call s:on_text_changed()
    augroup END
endfunc

func! s:debounce(last_curpos, _)
    if a:last_curpos == getcurpos()
        call s:start_complete()
    endif
endfunc

func! s:on_text_changed() abort
    call timer_start(g:aiocomplete_debounce_delay, function('s:debounce', [getcurpos()]))
endfunc

func! s:start_complete() abort
    let s:completions = {}
    let l:ctx = s:get_context()
    for [l:name, l:completor] in items(b:aiocompletors)
        call l:completor.complete(l:ctx, function('s:show_completions', [l:name]))
    endfor
endfunc

func! s:show_completions(name, ctx, startcol, completions)
    let l:ctx = s:get_context()
    if l:ctx != a:ctx
        return
    endif
    let l:completor = get(b:aiocompletors, a:name)

    for l:item in a:completions
        if has_key(s:completions, l:item['abbr'])
            if s:completions[l:item['abbr']].priority < l:completor.priority 
                let l:item['priority'] = l:completor.priority 
                let s:completions[l:item['abbr']] = l:item
            endif
        else
            let l:item['priority'] = l:completor.priority 
            let s:completions[l:item['abbr']] = l:item
        endif
    endfor

    call complete(a:startcol, values(s:completions))
endfunc

func! s:get_context() abort
    let l:pos = getcurpos()
    let l:ret = {}
    let l:ret['lnum'] = l:pos[1]
    let l:ret['col'] = l:pos[2]
    let l:ret['filetype'] = &filetype
    let l:ret['path'] = expand('%:p')
    let l:ret['typed'] = strpart(getline(l:ret['lnum']), 0, l:ret['col'] - 1)
    return l:ret
endfunc
