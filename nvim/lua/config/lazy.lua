--==============================================================================
-- Bootstrap lazy.nvim
--==============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Home Manager makes ~/.config/nvim read-only; keep lazy.nvim's generated
-- lockfile in XDG state (~/.local/state/nvim/lazy-lock.json) so :Lazy update
-- can write to it.
local lazy_lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json"
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

  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      require("nvim-tmux-navigation").setup({})

      local tmux_dirs = { h = "L", j = "D", k = "U", l = "R" }
      local tmux_edge_flags = {
        h = "pane_at_left",
        j = "pane_at_bottom",
        k = "pane_at_top",
        l = "pane_at_right",
      }

      local function navigate_no_wrap(direction)
        local winnr = vim.fn.winnr()
        pcall(vim.cmd, "wincmd " .. direction)
        if winnr ~= vim.fn.winnr() then
          return
        end
        if not vim.env.TMUX then
          return
        end
        local socket = vim.fn.split(vim.env.TMUX, ",")[1]
        local at_edge =
          vim.fn.system("tmux -S " .. socket .. " display-message -p '#{" .. tmux_edge_flags[direction] .. "}'")
        if vim.trim(at_edge) ~= "1" then
          vim.fn.system("tmux -S " .. socket .. " select-pane -" .. tmux_dirs[direction])
        end
      end

      vim.keymap.set("n", "<M-h>", function()
        navigate_no_wrap("h")
      end, { silent = true })
      vim.keymap.set("n", "<M-j>", function()
        navigate_no_wrap("j")
      end, { silent = true })
      vim.keymap.set("n", "<M-k>", function()
        navigate_no_wrap("k")
      end, { silent = true })
      vim.keymap.set("n", "<M-l>", function()
        navigate_no_wrap("l")
      end, { silent = true })
    end,
  },

  { "tpope/vim-abolish" },
  { "tpope/vim-surround" },
  { "tpope/vim-sleuth" },
  { "pocco81/auto-save.nvim" },
  { "vim-scripts/Tabmerge" },
  { "numToStr/Comment.nvim" },

  -- AI
  {
    "milanglacier/minuet-ai.nvim",
    enabled = vim.env.MISTRAL_API_KEY ~= nil and vim.env.MISTRAL_API_KEY ~= "",
    event = "InsertEnter",
    cmd = "Minuet",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("minuet").setup({
        provider = "codestral",
        provider_options = {
          codestral = {
            model = "codestral-2508",
            api_key = "MISTRAL_API_KEY",
            end_point = "https://api.mistral.ai/v1/fim/completions",
            stream = true,
          },
        },
        virtualtext = {
          auto_trigger_ft = { "c", "cpp", "lua", "nix", "python", "rust", "sh" },
          keymap = {
            accept = "<M-A>",
            accept_line = "<M-a>",
            accept_n_lines = "<M-z>",
            prev = "<M-[>",
            next = "<M-]>",
            dismiss = "<M-e>",
          },
        },
      })
    end,
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
    config = function(_, opts)
      vim.g.nvim_focused = true
      require("lualine").setup(opts)

      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          vim.g.nvim_focused = false
          require("lualine").refresh()
        end,
      })
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          vim.g.nvim_focused = true
          require("lualine").refresh()
        end,
      })
    end,
    opts = {
      sections = {
        lualine_a = {
          {
            "mode",
            cond = function()
              return vim.g.nvim_focused
            end,
          },
        },
        lualine_b = {
          {
            "branch",
            cond = function()
              return vim.g.nvim_focused
            end,
          },
          {
            "diff",
            cond = function()
              return vim.g.nvim_focused
            end,
          },
          {
            "diagnostics",
            cond = function()
              return vim.g.nvim_focused
            end,
          },
        },
        lualine_c = { { "filename", path = 1, file_status = true } },
        lualine_x = {
          {
            function()
              return require("direnv").statusline()
            end,
            cond = function()
              return vim.g.nvim_focused
            end,
          },
          {
            "encoding",
            cond = function()
              return vim.g.nvim_focused
            end,
          },
          {
            "fileformat",
            cond = function()
              return vim.g.nvim_focused
            end,
          },
          {
            "filetype",
            cond = function()
              return vim.g.nvim_focused
            end,
          },
        },
        lualine_y = {
          {
            "progress",
            cond = function()
              return vim.g.nvim_focused
            end,
          },
        },
        lualine_z = {
          {
            "location",
            cond = function()
              return vim.g.nvim_focused
            end,
          },
        },
      },
      inactive_sections = {
        lualine_c = { { "filename", path = 1, file_status = true, newfile_status = true } },
      },
      extensions = { "nvim-tree" },
    },
  },

  -- Direnv integration
  {
    "NotAShelf/direnv.nvim",
    opts = {
      autoload_direnv = true,
      statusline = { enabled = true },
    },
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
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
        "nix",
      })
    end,
  },
  { "nvim-treesitter/nvim-treesitter-context" },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local swap = require("nvim-treesitter-textobjects.swap")

      vim.keymap.set({ "x", "o" }, "aa", function()
        select.select_textobject("@parameter.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ia", function()
        select.select_textobject("@parameter.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "af", function()
        select.select_textobject("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "if", function()
        select.select_textobject("@function.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ac", function()
        select.select_textobject("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ic", function()
        select.select_textobject("@class.inner", "textobjects")
      end)
      vim.keymap.set("n", "<leader>a", function()
        swap.swap_next("@parameter.inner")
      end)
      vim.keymap.set("n", "<leader>A", function()
        swap.swap_previous("@parameter.inner")
      end)
    end,
  },

  -- Find and Replace
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>fr",
        function()
          require("grug-far").open({ transient = true })
        end,
        desc = "Find & Replace",
      },
      {
        "<leader>fw",
        function()
          require("grug-far").open({ transient = true, prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Find & Replace (word under cursor)",
      },
      {
        "<leader>fr",
        function()
          require("grug-far").open({
            transient = true,
            prefills = { search = require("grug-far").get_current_visual_selection() },
          })
        end,
        mode = "x",
        desc = "Find & Replace (selection)",
      },
    },
    opts = {
      engines = {
        ripgrep = {
          extraArgs = table.concat(require("config.rg-flags"), " "),
        },
      },
    },
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
          local rg_flags = require("config.rg-flags")
          require("telescope.builtin").find_files({
            find_command = vim.list_extend({ "rg", "--files" }, rg_flags),
          })
        end,
        desc = "Find files (ignore build dirs)",
      },
      {
        "<leader>fv",
        function()
          require("telescope.builtin").find_files({ find_command = { "rg", "--files", "--hidden", "--no-ignore" } })
        end,
        desc = "Find files (verbose)",
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
          local rg_flags = require("config.rg-flags")
          require("telescope.builtin").live_grep({ additional_args = rg_flags })
        end,
        desc = "Live grep",
      },
    },
  },

  -- Language server plugins
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("clangd", { capabilities = capabilities })
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })
      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              allTargets = true,
              targetDir = true,
            },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "with_block" },
              lifetimeElisionHints = { enable = "always", useParameterNames = false },
              maxLength = 25,
              parameterHints = { enable = true },
              reborrowHints = { enable = "always" },
              renderColons = true,
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
          },
        },
      })
      vim.lsp.config("ruff", { capabilities = capabilities })
      vim.lsp.config("ty", { capabilities = capabilities })
      vim.lsp.config("pyright", { capabilities = capabilities })

      vim.lsp.enable({ "clangd", "lua_ls", "rust_analyzer", "ruff", "ty" })
      if vim.fn.executable("pyright-langserver") == 1 then
        vim.lsp.enable("pyright")
      end

      local on_attach_common = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        vim.keymap.set("n", "<leader>vgD", function()
          vim.cmd("vsplit")
          vim.lsp.buf.declaration()
        end, bufopts)
        vim.keymap.set("n", "<leader>xgD", function()
          vim.cmd("split")
          vim.lsp.buf.declaration()
        end, bufopts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "<leader>vgd", function()
          vim.cmd("vsplit")
          vim.lsp.buf.definition()
        end, bufopts)
        vim.keymap.set("n", "<leader>xgd", function()
          vim.cmd("split")
          vim.lsp.buf.definition()
        end, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        vim.keymap.set("n", "<leader>ld", vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, bufopts)
        vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, bufopts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)

        if client.server_capabilities.inlayHintProvider then
          vim.keymap.set("n", "<leader>it", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
          end, { desc = "Toggle Inlay Hints", buffer = bufnr })
        end

        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        })
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          on_attach_common(client, ev.buf)
        end,
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
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
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
        python = { "isort", "ruff_format" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        bash = { "beautysh" },
        markdown = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        toml = { "prettier" },
      },
      formatters = {
        prettier = function(bufnr)
          if vim.bo[bufnr].filetype == "markdown" then
            -- Prettier's Markdown parser ignores range formatting; use Conform's diff filtering.
            local formatter = vim.deepcopy(require("conform.formatters.prettier"))
            formatter.inherit = false
            formatter.range_args = nil
            return formatter
          end
        end,
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
      local function available(linters)
        return vim.tbl_filter(function(name)
          return vim.fn.executable(name) == 1
        end, linters)
      end

      local lint_augroup = vim.api.nvim_create_augroup("nvim-lint-autogroup", { clear = true })
      require("lint").linters_by_ft = {
        bash = { "shellcheck" },
        c = { "clangtidy" },
        cpp = { "clangtidy" },
        python = available({ "pylint", "flake8", "mypy", "pyright" }),
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
}, {
  lockfile = lazy_lockfile,
})
