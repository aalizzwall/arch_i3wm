" --- 1. 基礎外觀 ---
syntax on                   " 開啟語法高亮
set number                  " 顯示行號
set relativenumber          " 顯示相對行號 (i3 玩家必備，方便跳行)
set cursorline              " 高亮當前行
set showmode                " 顯示當前模式
set laststatus=2            " 永遠顯示狀態列

" --- 2. 編輯行為 ---
set encoding=utf-8          " 編碼設定
set mouse=a                 " 開啟滑鼠支援 (有時候還是很好用)
set clipboard=unnamedplus   " 與系統剪貼簿同步 (需安裝 xclip 或 xsel)

" --- 3. 縮進設定 (程式碼排版) ---
set tabstop=4               " Tab 寬度
set shiftwidth=4            " 自動縮進寬度
set expandtab               " 用空白代替 Tab
set autoindent              " 自動縮進

" --- 4. 搜尋優化 ---
set hlsearch                " 高亮搜尋結果
set incsearch               " 邊打邊搜
set ignorecase              " 搜尋忽略大小寫
set smartcase               " 如果搜大寫，則不忽略大小寫

" 按下空格鍵取消搜尋高亮
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" --- 5. 強效編碼偵測 (防 Big5 亂碼) ---
" Vim 內部運作與終端機顯示永遠保持最高相容的 UTF-8
set encoding=utf-8
set termencoding=utf-8

" 開啟檔案時的「猜測順序」(這行是靈魂所在！)
" Vim 會由左至右嘗試解碼。順序極度重要：
" 1. ucs-bom: 先看檔案有沒有帶 BOM 頭
" 2. utf-8: 現代標準
" 3. big5 / cp950: 如果不是 UTF-8，優先嘗試傳統中文編碼
" 4. gb18030 / euc-jp / euc-kr: 涵蓋簡中與日韓文
" 5. latin1: 如果上面全失敗，用西方標準墊底，避免整個檔案壞掉
set fileencodings=ucs-bom,utf-8,big5,cp950,gb18030,euc-jp,euc-kr,latin1

" 存檔時的預設行為 (避免不小心把 Big5 檔案存成 UTF-8 覆蓋掉原本的格式)
set fileencoding=utf-8
