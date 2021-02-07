call plug#begin('~/.vim/plugged')

" vim-go plugin
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" struct split & join
Plug 'AndrewRadev/splitjoin.vim'
" golang snippets
" Plug 'SirVer/ultisnips'
" nerd-tree
Plug 'scrooloose/nerdtree'
" rust
Plug 'rust-lang/rust.vim'
" Tagbar
Plug 'majutsushi/tagbar'
" syntastic
Plug 'vim-syntastic/syntastic'
" cmake syntax
Plug 'pboettch/vim-cmake-syntax'
" google code-fmt
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
" lsp
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" markdown-preview
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

call plug#end()

set clipboard=unnamed
set nu
set autowrite
" indent related
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set smartindent
" for python indent
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 textwidth=79

set textwidth=80
set colorcolumn=80
set background=dark
" search related
set hlsearch
set incsearch
syntax enable
set showcmd

" set spell spelllang=en_us
" set listchars=tab:»■,trail:■
set listchars=trail:■
set list
set wildmenu
set wildmode=longest:list,full

" Use a blinking upright bar cursor in Insert mode, a blinking block in normal
" if &term == 'xterm-256color' || &term == 'screen-256color'
" let &t_SI = "\<Esc>[5 q"
" let &t_SR = "\<Esc>[4 q"
" let &t_EI = "\<Esc>[1 q"
" endif
" if exists('$TMUX')
"   let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
"    let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
"    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
"endif
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
    let &t_SR = "\<Esc>Ptmux;\<Esc>\e[3 q\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\e[1 q\<Esc>\\"
else
    let &t_SI = "\e[5 q"
    let &t_SR = "\e[3 q"
    let &t_EI = "\e[1 q"
endif

inoremap <special> <Esc> <Esc>hl
set guicursor+=i:blinkwait0
"set -s escape-time 0

filetype plugin on


" for golang
" <leader>b run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
" <leader>r = :GoRun
autocmd FileType go nmap <leader>r  <Plug>(go-run)
" <leader>t = :GoTest
autocmd FileType go nmap <leader>t  <Plug>(go-test)
" <leader>c = :GoConverageToggle
autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)

" automatically format and rewrite the import declarations when file saved
let g:go_fmt_command = "goimports"

" rust-vim config
let g:rustfmt_autosave = 1
let g:syntastic_rust_checkers = ['cargo']
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
map <leader>n :NERDTreeToggle<CR>
nnoremap <leader>a :cclose<CR>
imap <C-Space> <C-x><C-o>
nmap <F8> :TagbarToggle<CR>

" google code-fmt config
map F :FormatCode<CR>

augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript,arduino AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
  autocmd FileType java AutoFormatBuffer google-java-format
  " autocmd FileType python AutoFormatBuffer yapf
  autocmd FileType python AutoFormatBuffer autopep8
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType vue AutoFormatBuffer prettier
augroup END

" vim-lsp
if executable('pyls')
    " pip install python-language-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'allowlist': ['python'],
        \ })
endif

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <Plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" lsp-autocomplete config
" tab completion
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
" force refresh
imap <c-space> <Plug>(asyncomplete_force_refresh)

