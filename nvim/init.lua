--==============================================================================
-- Basic Neovim Settings
--==============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Keep failed/skipped secret injection visible in :messages as well as the launcher.
local secret_warning = vim.env.ONEPASSWORD_WARNING
vim.env.ONEPASSWORD_WARNING = nil
if secret_warning and secret_warning ~= "" then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(function()
        -- Keep the full warning in history without blocking on a hit-enter prompt.
        local messagesopt = vim.o.messagesopt
        vim.o.messagesopt = messagesopt:gsub("hit%-enter", "wait:0"):gsub("wait:%d+", "wait:0")
        vim.api.nvim_echo({ { vim.trim(secret_warning), "WarningMsg" } }, true, {})
        vim.o.messagesopt = messagesopt
      end)
    end,
  })
end

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

vim.keymap.set({ "n", "x" }, "<leader>sy", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("n", "<leader>sp", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("x", "<leader>sp", '"+P', { desc = "Paste from system clipboard - visual" })

vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")
vim.cmd("autocmd FileType gitcommit setlocal spell formatexpr=")
vim.cmd("autocmd FileType markdown setlocal spell")

-- Enable treesitter highlighting for languages with installed parsers
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

require("config.lazy")

vim.cmd.colorscheme("sonokai")
