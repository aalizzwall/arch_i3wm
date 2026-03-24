" ==============================================================================
" 🐧 Pascal's Ultimate Vimrc (Arch Linux Terminal & GUI)
" ==============================================================================

" --- 1. 基礎設定與 UI ---
set nocompatible
syntax on
filetype on
filetype plugin on
filetype indent on

set number
set relativenumber      " i3wm 玩家神兵：相對行號，方便 10j, 5k 快速跳躍
set ruler
set history=1000
set showmatch           " 括號高亮匹配
set laststatus=2        " 永遠顯示狀態列
set cmdheight=1         " 命令行高度

" 視覺與游標
set cursorline
highlight CursorLine guibg=#0E6A0E ctermbg=236
set vb t_vb=            " 關閉錯誤閃爍提示 (belling)

" 搜尋設定
set hlsearch            " 搜尋高亮
set incsearch           " 邊打邊搜
set ignorecase          " 忽略大小寫
set smartcase           " 有大寫時精確匹配
" 按空白鍵快速消除搜尋高亮
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" --- 2. 編碼大一統 (取代舊版複雜的 locale 判斷) ---
set encoding=utf-8
" 動態猜測順序：BOM -> UTF-8 -> 繁中(cp950) -> 簡中(cp936/gb18030) -> 日韓 -> 西洋
set fileencodings=ucs-bom,utf-8,cp950,cp936,cp18030,sjis,euc-jp,euc-kr,latin1
set fileformats=unix,dos

" 遇到雙字串顯示問題時的處理 (於現代終端機建議維持預設 single，GUI 則 double)
if has("gui_running")
    set ambiwidth=double
else
    set ambiwidth=single
endif

" --- 3. 縮排與排版 ---
set autoindent
set smartindent
set et                  " expandtab (Tab 轉空白)
set ts=2                " tabstop=2
set sw=2                " shiftwidth=2
set cino=>2             " C/C++ 縮排風格

" C/C++ 註解自動補齊修正
set comments=://
set comments=s1:/*,mb:*,ex0:/

" 增強檢索與目錄
set tags=./tags,./../tags,./**/tags
set bsdir=buffer        " 文件瀏覽器目錄設為當前目錄
if has("vim_starting")
    set autochdir       " 自動切換當前目錄為開啟檔案之目錄
endif

" --- 4. 檔案防護與持久化復原 (Modern Arch 優化) ---
set uc=0                " 停用惹人厭的 .swp 暫存檔
set noswf               " 停用 swapfile
" 取而代之的是強大的持久化復原 (關閉檔案再開也能 undo!)
if has('undofile')
    set undodir=~/.vim/undo//
    set undofile
endif

" --- 5. 強悍的快捷鍵映射 (Key Mappings) ---
" 折行移動優化
map <Up> gk
map <Down> gj

" 快速翻頁
map <S-PageUp> <C-u>
map <S-PageDown> <C-d>

" GF 強化：在新分頁開啟游標下的檔案路徑
nmap gf :tabedit <cfile><CR>

" Ctrl+S 儲存 (相容各模式)
noremap <C-S> :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <C-O>:update<CR>

" 剪貼簿大一統 (Arch 下只要有裝 xclip 即可完美跟系統互通)
set clipboard=unnamedplus
" 保留你習慣的 Ctrl+Y 與 Ctrl+P
vnoremap <C-Y> "+y
map <C-P> "+gP
imap <C-P> <C-O>"+gP
cmap <C-P> <C-R>+

" 外部工具呼叫
" 呼叫 dict 翻譯游標下的單字
map <C-K> viwy:!clear; dict <C-R>"<CR>
" 呼叫 devhelp (需安裝 GNOME devhelp)
function! DevHelpCurrentWord()
    let word = expand("<cword>")
    exe "!devhelp -s " . word
endfunction
nmap <ESC>H :call DevHelpCurrentWord()<CR>

" 駭客神技：一鍵切換 Hex (16進位) 編輯模式
nmap <C-F7> :%!xxd -g 1<CR>
nmap <S-F7> :%!xxd -r<CR>

" 開啟 NERDTree (若有安裝該外掛)
nnoremap <silent> <C-L> :NERDTree "$PWD"<CR>

" --- 6. 自動化與自訂函式 ---
" 清除行尾多餘空白 (存檔時不自動執行，以免影響編輯，保留呼叫能力)
function RemoveTrailingWhitespace()
    if &ft != "diff"
        let b:curcol = col(".")
        let b:curline = line(".")
        silent! %s/\s\+$//
        silent! %s/\(\s*\n\)\+\%$//
        call cursor(b:curline, b:curcol)
    endif
endfunction
command! CleanSpace call RemoveTrailingWhitespace()

" 智慧記憶游標位置：下次開啟檔案時，回到上次編輯的地方
au BufReadPost * if line("'\"") > 0|if line("'\"")
