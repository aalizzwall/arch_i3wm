# 🐧 Pascal's Arch Linux Dotfiles (Dual-Machine Setup)

這是我專屬的 Arch Linux 環境設定檔，針對 **MacBook Pro 2015 (Retina)** 與 **m6s (Mini PC)** 進行了深度優化。
採用 **Git Bare Repository** 模式管理，直接將 `$HOME` 作為工作區，無需使用 Symlinks。

## 💻 硬體目標與優化重點

### 1. MacBook Pro 2015 (Intel Broadwell)
* **顯示驅動:** 必須使用 `xf86-video-intel` 以確保 Xorg 穩定
* **散熱與電源:** 透過 `mbpfan` 接管 Apple SMC 風扇控制；使用 `tlp` 優化電池續航力。
* **網路:** 經測試，使用現代化 `iwd` 搭配原生 `brcmfmac` 驅動最為穩定
* **音量:** 整合 `PipeWire` (`wpctl`) 快捷鍵，具備自動解除靜音與 100% 音量限制。

### 2. m6s (N100 Mini PC)
* **顯示:** 使用現代 `intel-media-driver` 提供 4K 硬體解碼。

---

## 🚀 快速還原指南 (New Machine / Restore)

當拿到一台全新安裝好 Arch Linux 基礎系統的電腦時，請依序執行以下步驟：

### 1. 基礎工具與安裝 yay
在新系統上，必須先手動編譯安裝 AUR 幫手 `yay`，接著再處理 SSH 連線：

```bash
# 安裝編譯基礎包、Git 與 OpenSSH
sudo pacman -S --needed base-devel git openssh

# 手動編譯安裝 yay
git clone [https://aur.archlinux.org/yay.git](https://aur.archlinux.org/yay.git)
cd yay
makepkg -si
cd .. && rm -rf yay

# 產生 SSH 金鑰並加入 GitHub ([https://github.com/settings/keys](https://github.com/settings/keys))
ssh-keygen -t ed25519 -C "p331090144@hotmail.com"
cat ~/.ssh/id_ed25519.pub

# 取回基本設定檔
# 暫時定義專屬 alias
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# 確保不會發生循環遞迴
echo ".dotfiles" >> ~/.gitignore

# Clone 裸倉庫
git clone --bare git@github.com:aalizzwall/arch_i3wm.git $HOME/.dotfiles

# 鋪設設定檔 (若提示 .bashrc 等檔案衝突，請先備份或刪除舊檔案再執行一次)
# rm ~/.bashrc
dot checkout

# 隱藏未追蹤檔案，保持 Git Status 清潔
dot config --local status.showUntrackedFiles no

