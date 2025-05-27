--==============================================================================
-- Bootstrap lazy.nvim
--==============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

--==============================================================================
-- Plugins with lazy.nvim
--==============================================================================
require("lazy").setup({
  -- Theme: Sonokai
  { "sainnhe/sonokai" },

  { "tpope/vim-abolish" },
  { "tpope/vim-surround" },
  { "tpope/vim-sleuth" },
  { "pocco81/auto-save.nvim" },
  { "vim-scripts/Tabmerge" },
  { "numToStr/Comment.nvim" },

  -- AI
  {
    "olimorris/codecompanion.nvim",
    dependencies = { "j-hui/fidget.nvim" },
    cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionCmd", "CodeCompanionChat" },
    keys = {
      { "<leader>aip", "<cmd>CodeCompanionActions<CR>", desc = "CodeCompanion AI action palette" },
      { "<leader>aic", "<cmd>CodeCompanionChat<CR>", desc = "CodeCompanion AI chat" },
    },
    opts = {
      strategies = {
        chat = { adapter = "gemini" },
        inline = { adapter = "gemini" },
        cmd = { adapter = "gemini" },
      },
      opts = { log_level = "DEBUG" },
    },
  },

  -- Git Integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map("n", "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(gs.next_hunk)
            return "<Ignore>"
          end, { expr = true, desc = "Next Git Hunk" })
          map("n", "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(gs.prev_hunk)
            return "<Ignore>"
          end, { expr = true, desc = "Previous Git Hunk" })
        end,
      })
    end,
  },
  { "akinsho/git-conflict.nvim", version = "*", config = true },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" } },
      { "<leader>o", "<cmd>NvimTreeFindFile<CR>", { desc = "Find file" } },
    },
    opts = { view = { width = 40 } },
  },

  -- Status Line
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        lualine_c = { { "filename", path = 1, file_status = true } },
      },
      inactive_sections = {
        lualine_c = { { "filename", path = 1, file_status = true, newfile_status = true } },
      },
      extensions = { "nvim-tree", "mason" },
    },
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c",
          "cpp",
          "rust",
          "python",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown",
          "json",
          "yaml",
          "toml",
          "bash",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  { "nvim-treesitter/nvim-treesitter-context" },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = false,
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },

  -- Fuzzy Finder: Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({ find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" } })
        end,
        desc = "Find files",
      },
      {
        "<leader>ft",
        function()
          require("telescope.builtin").treesitter()
        end,
        desc = "Search treesitter",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep",
      },
    },
  },

  -- Language server plugins
  {
    "williamboman/mason.nvim",
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
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "clangd",
        "lua_ls",
        "rust_analyzer",
      },
      automatic_enable = false,
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities_cmp = require("cmp_nvim_lsp").default_capabilities()

      local on_attach_common = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        vim.keymap.set("n", "<leader>ld", vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, bufopts)
        vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, bufopts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        })
      end
      lspconfig.rust_analyzer.setup({ capabilities = capabilities_cmp, on_attach = on_attach_common })
      lspconfig.clangd.setup({ capabilities = capabilities_cmp, on_attach = on_attach_common })
      lspconfig.lua_ls.setup({
        capabilities = capabilities_cmp,
        on_attach = on_attach_common,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
      vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Open diagnostics float" })
      vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostics quickfix list" })
    end,
  },

  -- Formatting: conform.nvim
  {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Formatting buffer with conform",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        bash = { "beautysh" },
        markdown = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        toml = { "prettier" },
      },
    },
  },

  -- Linting: nvim-lint
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost", "InsertLeave" },
    keys = {
      {
        "<leader>cl",
        function()
          require("lint").try_lint()
        end,
        desc = "Trigger linting",
      },
    },
    config = function()
      local lint_augroup = vim.api.nvim_create_augroup("nvim-lint-autogroup", { clear = true })
      require("lint").linters_by_ft = {
        bash = { "shellcheck" },
        c = { "clangtidy" },
        cpp = { "clangtidy" },
        python = { "pylint", "flake8", "mypy" },
        rust = { "clippy" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, {
        group = lint_augroup,
        callback = function(args)
          require("lint").try_lint(nil, { bufnr = args.buf })
        end,
      })
    end,
  },

  -- Autocompletion: nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp-signature-help",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      local sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "luasnip" },
        { name = "buffer", keyword_length = 3 },
        { name = "path" },
      }

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fb)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fb()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fb)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fb()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(sources),
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
      cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
    end,
  },
})
