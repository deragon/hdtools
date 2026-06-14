" The code found in this file must always work for both vim and neovim (nvim).
" Tests files for testing the wrapping code below are located at
" .env/vim/tests/wrap

" Disable automatic text wrapping for code lines.
set formatoptions-=t

" This sets textwidth to wrap at the specified width
function! HDWrapWithBulletIndent(textwidth)
  execute 'set textwidth=' . a:textwidth
  " Temporarily clear formatexpr and indentexpr so gq uses Vim's built-in
  " formatter (with formatlistpat hanging indent) instead of any LSP/plugin
  " formatter (e.g. LazyVim's formatexpr / treesitter indentexpr).
  let l:saved_formatexpr = &formatexpr
  let l:saved_indentexpr = &indentexpr
  set formatexpr=
  set indentexpr=
  " In Git commit messages, keep the metadata block (# ...) untouched when
  " wrapping the summary/body line right above it.
  let l:is_commit_editmsg = (&filetype ==# 'gitcommit') || (expand('%:t') ==# 'COMMIT_EDITMSG')
  let l:on_non_comment = getline('.') !~# '^\s*#'
  let l:next_is_comment = getline(line('.') + 1) =~# '^\s*#'
  if l:is_commit_editmsg && l:on_non_comment && l:next_is_comment
    call HDWrapCurrentLineOnly(a:textwidth)
  else
    normal! gqap
  endif
  let &formatexpr = l:saved_formatexpr
  let &indentexpr = l:saved_indentexpr
endfunction

" Wrap only the current line and replace it with wrapped lines.
" This avoids gq spilling text into following lines (important for COMMIT_EDITMSG
" where the next lines are git metadata comments that must remain untouched).
function! HDWrapCurrentLineOnly(textwidth)
  let l:line_text = getline('.')
  let l:indent = matchstr(l:line_text, '^\s*')
  let l:content = substitute(l:line_text, '^\s*', '', '')
  let l:words = split(l:content, '\s\+')

  if empty(l:words)
    return
  endif

  let l:max_width = a:textwidth - strdisplaywidth(l:indent)
  if l:max_width <= 1
    let l:max_width = 1
  endif

  let l:wrapped = []
  let l:current = ''
  for l:word in l:words
    if empty(l:current)
      let l:current = l:word
    elseif strdisplaywidth(l:current . ' ' . l:word) <= l:max_width
      let l:current .= ' ' . l:word
    else
      call add(l:wrapped, l:indent . l:current)
      let l:current = l:word
    endif
  endfor

  if !empty(l:current)
    call add(l:wrapped, l:indent . l:current)
  endif

  call setline('.', l:wrapped[0])
  if len(l:wrapped) > 1
    call append(line('.'), l:wrapped[1:])
  endif
endfunction

" Wrap an inline comment (code followed by  " # ") with proper continuation
" prefix alignment.  E.g.:
"   cmd arg # long comment...
" becomes:
"   cmd arg # wrapped comment
"           # continued here
function! HDWrapInlineComment(textwidth)
  let l:line     = getline('.')
  let l:hash_idx = match(l:line, ' # ')
  if l:hash_idx < 0
    return
  endif
  " Prefix: everything up to and including "# " (space + hash + space = 3 chars)
  let l:prefix      = strpart(l:line, 0, l:hash_idx + 3)
  " Continuation indent: spaces aligned to the # column, then "# "
  let l:cont_prefix = repeat(' ', l:hash_idx + 1) . '# '
  let l:content     = strpart(l:line, l:hash_idx + 3)
  let l:words       = split(l:content, '\s\+')
  if empty(l:words)
    return
  endif

  let l:max_w    = a:textwidth - strdisplaywidth(l:prefix)
  let l:max_cont = a:textwidth - strdisplaywidth(l:cont_prefix)
  let l:wrapped  = []
  let l:cur      = ''
  let l:first    = 1

  for l:word in l:words
    if empty(l:cur)
      let l:cur = l:word
    elseif strdisplaywidth(l:cur . ' ' . l:word) <= (l:first ? l:max_w : l:max_cont)
      let l:cur .= ' ' . l:word
    else
      call add(l:wrapped, (l:first ? l:prefix : l:cont_prefix) . l:cur)
      let l:first = 0
      let l:cur   = l:word
    endif
  endfor
  if !empty(l:cur)
    call add(l:wrapped, (l:first ? l:prefix : l:cont_prefix) . l:cur)
  endif

  call setline('.', l:wrapped[0])
  if len(l:wrapped) > 1
    call append(line('.'), l:wrapped[1:])
  endif
endfunction

" Main wrapping entry point using par as the formatting engine.
" Replaces HDWrapWithBulletIndent in key mappings; old functions are kept.
"
" Routing logic:
"   1. COMMIT_EDITMSG body line before # metadata  -> HDWrapCurrentLineOnly
"   2. Inline comment (code + " # " comment)       -> HDWrapInlineComment
"   3. Bullet list line (-, *, +, 1.)               -> vim built-in gqap
"                                                      (par loses hanging indent)
"   4. # comment paragraph                          -> par w{N} p2
"   5. Plain text paragraph                         -> par w{N} p0 s0
function! HDWrapWithPar(textwidth)
  let l:line           = getline('.')
  let l:on_non_comment = l:line !~# '^\s*#'
  let l:next_is_comment = getline(line('.') + 1) =~# '^\s*#'

  " 1. COMMIT_EDITMSG
  let l:is_commit = (&filetype ==# 'gitcommit') || (expand('%:t') ==# 'COMMIT_EDITMSG')
  if l:is_commit && l:on_non_comment && l:next_is_comment
    call HDWrapCurrentLineOnly(a:textwidth)
    return
  endif

  " 2. Inline comment
  if l:on_non_comment && match(l:line, ' # ') >= 0
    call HDWrapInlineComment(a:textwidth)
    return
  endif

  " 3. Bullet list — par does not produce hanging indentation
  if l:line =~# '^\s*[-*+] \|^\s*\d\+\.\s'
    let l:saved_formatexpr = &formatexpr
    let l:saved_indentexpr = &indentexpr
    set formatexpr=
    set indentexpr=
    execute 'set textwidth=' . a:textwidth
    normal! gqap
    let &formatexpr = l:saved_formatexpr
    let &indentexpr = l:saved_indentexpr
    return
  endif

  " 4 & 5. Blank line — nothing to wrap.
  if l:line =~# '^\s*$'
    return
  endif

  " Find the paragraph the cursor sits in, stopping at blank lines,
  " at a change between comment/non-comment, or at an indentation change
  " (so indented inline-comment continuations don't merge with a following
  " standalone # comment block).
  let l:is_comment = !l:on_non_comment
  let l:cur        = line('.')
  let l:cur_indent = matchstr(getline(l:cur), '^\s*')

  let l:start = l:cur
  while l:start > 1
    let l:prev = getline(l:start - 1)
    if l:prev =~# '^\s*$' || (l:is_comment != (l:prev =~# '^\s*#'))
          \ || matchstr(l:prev, '^\s*') !=# l:cur_indent
      break
    endif
    let l:start -= 1
  endwhile

  let l:end = l:cur
  while l:end < line('$')
    let l:next = getline(l:end + 1)
    if l:next =~# '^\s*$' || (l:is_comment != (l:next =~# '^\s*#'))
          \ || matchstr(l:next, '^\s*') !=# l:cur_indent
      break
    endif
    let l:end += 1
  endwhile

  " Run par on the identified range.
  "   p{n} s0 g = preserve n-char indent prefix; g preserves double spaces
  "              after sentence-ending punctuation
  let l:p = strdisplaywidth(l:cur_indent)
  if l:is_comment
    execute l:start . ',' . l:end . '!par w' . a:textwidth . ' p2 s0 g'
  else
    execute l:start . ',' . l:end . '!par w' . a:textwidth . ' p' . l:p . ' s0 g'
  endif
endfunction

" <Leader>gg 'g' stands for 'git', to follow convention documented at:
"        http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
nnoremap <Leader>wg :call HDWrapWithPar(72)<CR>
nnoremap <Leader>w5 :call HDWrapWithPar(50)<CR>
nnoremap <Leader>w6 :call HDWrapWithPar(60)<CR>
nnoremap <Leader>w7 :call HDWrapWithPar(70)<CR>
nnoremap <Leader>w8 :call HDWrapWithPar(80)<CR>

MapToggle <Leader>ww wrap

" Center for 80 char screen
nnoremap <Leader>wc :ce 80<CR>
