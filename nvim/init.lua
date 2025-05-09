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

vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
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
vim.keymap.set({"n", "i", "v"}, "<F10>", "<cmd>set invspell<CR>", { silent = true, desc = "Toggle Spell Check" })
vim.keymap.set({"n", "i", "v"}, "<F11>", "<cmd>set invpaste<CR>", { silent = true, desc = "Toggle Paste Mode" })
vim.keymap.set({"n", "i", "v"}, "<F12>", "<cmd>set invrelativenumber<CR>", { silent = true, desc = "Toggle Relative Number" })
vim.keymap.set("n", "<Right>", "<C-w><Right>", { desc = "Window Nav: Right" })
vim.keymap.set("n", "<Left>", "<C-w><Left>", { desc = "Window Nav: Left" })
vim.keymap.set("n", "<Up>", "<C-w><Up>", { desc = "Window Nav: Up" })
vim.keymap.set("n", "<Down>", "<C-w><Down>", { desc = "Window Nav: Down" })

--==============================================================================
-- Bootstrap lazy.nvim
--==============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--==============================================================================
-- Plugins with lazy.nvim
--==============================================================================
require("lazy").setup({
  -- Theme: Sonokai
  {
    "sainnhe/sonokai", lazy = false, priority = 1000,
    config = function()
      vim.cmd.colorscheme "sonokai"
    end,
  },

  -- Pope Classics
  { "tpope/vim-abolish" },
  { "tpope/vim-surround" },

  -- Clipboard for remote/tmux (OSC 52)
  { "ojroques/nvim-osc52", lazy = true },

  -- Git Integration
  {
    "lewis6991/gitsigns.nvim", event = {"BufReadPre", "BufNewFile"},
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts) opts = opts or {}; opts.buffer = bufnr; vim.keymap.set(mode, l, r, opts) end
          map('n', ']c', function() if vim.wo.diff then return ']c' end; vim.schedule(gs.next_hunk); return '<Ignore>' end, {expr=true, desc = "Next Git Hunk"})
          map('n', '[c', function() if vim.wo.diff then return '[c' end; vim.schedule(gs.prev_hunk); return '<Ignore>' end, {expr=true, desc = "Previous Git Hunk"})
          map({'n', 'v'}, '<leader>hs', gs.stage_hunk, {desc="Stage Git Hunk"})
          map('n', '<leader>hS', gs.stage_buffer, {desc="Stage Git Buffer"})
        end
      })
    end,
  },

  -- Commenting
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {}, config = function(_,opts) require("Comment").setup(opts) end },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" }, cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle" },
    lazy = false,
    config = function()
      require("nvim-tree").setup({ update_focused_file = { enable = true, update_cwd = true }})
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
      vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle File Explorer and Find File"})
    end,
  },

  -- Status Line
  {
    "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
        sections = {
          lualine_a = {'mode'}, lualine_b = {'branch', 'diff'},
          lualine_c = {{'diagnostics', sources={"nvim_diagnostic"}}},
          lualine_x = {'encoding', 'fileformat', 'filetype'}, lualine_y = {'progress'}, lualine_z = {'location'}
        },
        extensions = {'nvim-tree', 'mason'}
      })
    end,
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", event = {"BufReadPre", "BufNewFile"},
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "rust", "python", "lua", "vim", "vimdoc", "query", "markdown", "json", "yaml", "toml", "bash" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Fuzzy Finder: Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    lazy = false,
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ft", builtin.treesitter, { desc = "Search treesitter" })
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
      vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find Old Files (History)" })
    end,
  },

  -- LSP, Formatter, Linter Management: Mason
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        -- Linters
        "clang-tidy",
        "mypy",
        "flake8",
        "pylint",
        "shellcheck",
        -- Formatters
        "black",
        "isort",
        "stylua",
        "shfmt",
        "prettier",
      }
    }
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = "VeryLazy",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "rust_analyzer",
          "clangd",
          "lua_ls",
        },
        automatic_installation = true, 
      })
    end,
  },

  -- Formatting: conform.nvim (Format-on-save disabled)
  {
    "stevearc/conform.nvim",
    cmd = { "Search treesitter" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" }, python = { "isort", "black" }, rust = { "rustfmt" },
        c = { "clang_format" }, cpp = { "clang_format" }, bash = { "shfmt" },
        markdown = { "prettier" }, json = { "prettier" }, yaml = { "prettier" }, toml = { "prettier" },
      },
    },
    lazy = false,
    config = function(_, opts)
        require("conform").setup(opts)
        vim.api.nvim_create_user_command("Format", function(args) require("conform").format({ async = true, lsp_fallback = true, quiet = args.quiet }) end, { bang = true, desc = "Format buffer" })
        vim.keymap.set({ "n", "v" }, "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format code" })
    end,
  },

  -- Linting: nvim-lint
  {
    "mfussenegger/nvim-lint", event = { "BufWritePost", "BufReadPost", "InsertLeave" },
    lazy = false,
    config = function()
      local lint_augroup = vim.api.nvim_create_augroup("nvim-lint-autogroup", { clear = true })
      require("lint").linters_by_ft = {
        python = { "pylint", "flake8", "mypy" },
        cpp = { "clangtidy" }, c = { "clangtidy" }, bash = { "shellcheck" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, {
        group = lint_augroup, callback = function(args) require("lint").try_lint(nil, { bufnr = args.buf }) end,
      })
      vim.keymap.set("n", "<leader>cl", function() require("lint").try_lint() end, { desc = "Trigger linting" })
    end,
  },

  -- LSP Configuration: nvim-lspconfig
  {
    "neovim/nvim-lspconfig", dependencies = {"hrsh7th/cmp-nvim-lsp"}, event = "VeryLazy",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities_cmp = require('cmp_nvim_lsp').default_capabilities()
      local capabilities = capabilities_cmp
      if package.loaded["parrot"] and require("parrot").get_capabilities then
        local parrot_capabilities = require("parrot").get_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities_cmp, parrot_capabilities)
      end

      local on_attach_common = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts); vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts); vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        vim.keymap.set("n", "<leader>ld", vim.lsp.buf.type_definition, bufopts); vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, bufopts)
        vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, bufopts); vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        vim.diagnostic.config({ virtual_text = true, signs = true, underline = true, update_in_insert = false, severity_sort = true })
      end
      lspconfig.rust_analyzer.setup({ capabilities = capabilities, on_attach = on_attach_common })
      lspconfig.clangd.setup({ capabilities = capabilities, on_attach = on_attach_common })
      lspconfig.pyright.setup({ capabilities = capabilities, on_attach = on_attach_common })
      lspconfig.lua_ls.setup({ capabilities = capabilities, on_attach = on_attach_common, settings = { Lua = { diagnostics = { globals = {'vim'} } } } })

      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
      vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Open diagnostics float" })
      vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostics quickfix list" })
    end,
  },

  -- AI: Parrot.nvim
  {
    "frankroeder/parrot.nvim", cmd = { "Parrot", "ParrotExplain", "ParrotRefactor", "ParrotFix", "ParrotImplement", "ParrotTest", "ParrotFree" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("parrot").setup({
        -- Ensure you configure API keys and models per parrot.nvim documentation
      })
      print("Parrot.nvim loaded. Configure API keys/models in its setup.")
    end,
  },

  -- Autocompletion: nvim-cmp
  {
    "hrsh7th/nvim-cmp", event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "hrsh7th/cmp-nvim-lsp-signature-help",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      local sources = {
          { name = "nvim_lsp" }, { name = "nvim_lsp_signature_help" }, { name = "luasnip" },
          { name = "buffer", keyword_length = 3 }, { name = "path" },
      }

      local parrot_cmp_ok, parrot_cmp = pcall(require, "parrot.cmp")
      if parrot_cmp_ok and parrot_cmp.source then
          table.insert(sources, 1, { name = "parrot" })
          parrot_cmp.setup()
      end

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(), ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-Space>"] = cmp.mapping.complete(), ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fb) if cmp.visible() then cmp.select_next_item() elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump() else fb() end end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fb) if cmp.visible() then cmp.select_prev_item() elseif luasnip.jumpable(-1) then luasnip.jump(-1) else fb() end end, { "i", "s" }),
        }),
        sources = cmp.config.sources(sources),
      })
      cmp.setup.cmdline(":", { mapping = cmp.mapping.preset.cmdline(), sources = cmp.config.sources({{ name = "path" }}, {{ name = "cmdline" }})})
      cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
    end,
  },

  -- Snippet Engine
  { "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" }, event = "InsertEnter", config = function() require("luasnip.loaders.from_vscode").lazy_load() end },

  -- Auto Save
  { "pocco81/auto-save.nvim", event = "VeryLazy", opts = { enabled = true, trigger_events = {"InsertLeave", "TextChanged"}, debounce_delay = 1500 } },
})

--==============================================================================
-- Autocommands (Post-Plugin Setup)
--==============================================================================
local augroup_yank = vim.api.nvim_create_augroup("MyYankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup_yank,
  pattern = "*",
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 }) end,
})
