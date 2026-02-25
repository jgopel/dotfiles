--==============================================================================
-- Basic Neovim Settings
--==============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Editor behavior
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "80"
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.autoread = true

-- Tabs and Indentation
vim.opt.tabstop = 8
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:2"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.mouse = "a"
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.shortmess:append("c")

-- Backup and swap files
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Project local vimrc
vim.opt.exrc = true
vim.opt.secure = true

-- Filetype detection and indentation
vim.cmd("filetype plugin indent on")

-- Custom Keybindings
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })
vim.keymap.set({ "n", "i", "v" }, "<F10>", "<cmd>set invspell<CR>", { silent = true, desc = "Toggle Spell Check" })
vim.keymap.set({ "n", "i", "v" }, "<F11>", "<cmd>set invpaste<CR>", { silent = true, desc = "Toggle Paste Mode" })
vim.keymap.set(
  { "n", "i", "v" },
  "<F12>",
  "<cmd>set invrelativenumber<CR>",
  { silent = true, desc = "Toggle Relative Number" }
)

vim.keymap.set({ "n", "x" }, "sy", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("n", "sp", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("x", "sp", '"+P', { desc = "Paste from system clipboard - visual" })

vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")
vim.cmd("autocmd FileType gitcommit setlocal spell")
vim.cmd("autocmd FileType markdown setlocal spell")

require("config.lazy")

vim.cmd.colorscheme("sonokai")
