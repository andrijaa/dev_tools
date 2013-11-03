" PATHOGEN
call pathogen#infect()
call pathogen#helptags()

" COLORS
syntax on
filetype plugin indent on

set background=dark

" Better surround
let g:surround_40 = "(\r)"
let g:surround_91 = "[\r]"
let g:surround_60 = "<\r>"

set tabstop=4
set shiftwidth=4
set expandtab

set backup              " keep a backup file
set backupdir=~/.vim/backups
set history=100         " keep 50 lines of command line history
set ruler               " show the cursor position all the time
"set showcmd            " display incomplete commands
set incsearch           " do incremental searching
set helpheight=1000
set ignorecase

set completeopt=longest,menu,preview
set wildmode=longest,list:longest
set complete=.,t

setlocal numberwidth=3

" FIXED THE ISSUE WITH BACKSPACE NOT WORKING
set backspace=indent,eol,start

" status line. stolen from here:
" " https://github.com/lukaszkorecki/DotFiles/blob/master/vimrc
set statusline=
set statusline+=%f\ %2*%m\ %1*%h
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%{fugitive#statusline()}
set statusline+=%*
set statusline+=%r%=[%{&encoding}\ %{&fileformat}\ %{strlen(&ft)?&ft:'none'}]
set statusline+=%15.(%c:%l/%L%)\ %P
set laststatus=2

"Keep swap files in one of these 
set directory=~/tmp,/var/tmp,/tmp,.

" " Syntastic
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=1

autocmd BufNewFile,BufRead *.css set fdm=marker fmr={,}

set hlsearch
set listchars=tab:>-,trail:-
hi IncSearch term=reverse gui=underline guibg=Blue  guifg=Yellow
hi    Search term=reverse gui=underline guibg=Black guifg=Yellow
hi    Visual term=reverse cterm=reverse ctermbg=9 guibg=#555577 guifg=Black

hi Pmenu      guifg=White guibg=Blue
hi PmenuSel   gui=italic guifg=Yellow guibg=Blue
hi PmenuSbar  ctermbg=Black guibg=Grey
hi PmenuThumb guifg=Yellow guibg=Black

if has("gui_running")
  set lines=80 
  set columns=120 
  set number
endif

if has("gui_macvim")
  " write on pretty much any event (including :q) 
  set autowriteall
  set tabpagemax=100
  "set guifont=Inconsolata:h20,\ DejaVu\ Sans\ Mono:h15
  set guifont=Monofur:h20
  " set guifont=Consolas:h18
endif


