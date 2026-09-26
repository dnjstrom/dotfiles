-- luacheck: globals vim, ignore 113

local map = vim.keymap.set

-------------------------------------------------------------------------------
-- General options
-------------------------------------------------------------------------------

--Relative numbers
vim.o.number = true
vim.o.relativenumber = true

-- Sane tab size defaults
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- UI
vim.opt.cursorline = false
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.o.cmdheight = 0

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

-- Keep more context around the cursor
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Better split defaults
vim.opt.splitbelow = true
vim.opt.splitright = true

-- System clipboard
vim.opt.clipboard = "unnamedplus"

-- Faster feedback for LSP/plugins
vim.opt.updatetime = 200

-- Persistent undo
vim.opt.undofile = true

-- Better command-line completion
vim.opt.wildmode = "longest:full,full"

-- Don't highlight every search result forever
vim.opt.hlsearch = false

-- Show substitutions incrementally
vim.opt.inccommand = "split"

-------------------------------------------------------------------------------
-- Theme
-------------------------------------------------------------------------------

vim.pack.add({
  "https://github.com/gbprod/nord.nvim",
})

vim.cmd.colorscheme("nord")

-------------------------------------------------------------------------------
-- Treesitter
-------------------------------------------------------------------------------

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

require("nvim-treesitter").install({
  "lua",
  "nix",
  "vim",
  "vimdoc",
  "query",
  "bash",
  "json",
  "yaml",
  "toml",
  "markdown",
  "markdown_inline",
  "javascript",
  "typescript",
  "tsx",
  "python",
  "graphql",
  "prisma",
})

-- Start treesitter highlighting for any filetype with an installed parser.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-------------------------------------------------------------------------------
-- Keybinding hints
-------------------------------------------------------------------------------

vim.pack.add({
  "https://github.com/folke/which-key.nvim",
})

require("which-key").setup({
  preset = "modern",
})

-------------------------------------------------------------------------------
-- Language Servers
-------------------------------------------------------------------------------
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/folke/lazydev.nvim",
})


-- Get autocomplete in init.lua
require("lazydev").setup()

-- Enable lsp and auto formatting for nix-files
vim.lsp.config('nixd', {
  settings = {
    formatting = {
      command = { 'nixfmt' },
    },
  },
})

vim.lsp.enable({ 'nixd', 'lua-lsp', 'ts_ls', 'biome', 'ty' })

-------------------------------------------------------------------------------
-- Git integration
-------------------------------------------------------------------------------

vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
})
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")

    --- Jump to the next hunk, or the next diff change when in diff mode.
    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, { buffer = bufnr, desc = "Next git hunk" })

    --- Jump to the previous hunk, or the previous diff change when in diff mode.
    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, { buffer = bufnr, desc = "Previous git hunk" })
  end,
})

vim.pack.add({ "https://github.com/esmuellert/codediff.nvim" })

-- nord's DiffAdd/DiffDelete (codediff's default line_insert/line_delete) set
-- both fg and bg with reverse=true, which replaces syntax colors entirely
-- instead of just tinting the background. Define bg-only groups instead.
do
  local nord_colors = require("nord.colors").palette
  local nord_utils = require("nord.utils")
  local editor_bg = nord_colors.polar_night.origin

  vim.api.nvim_set_hl(0, "CodeDiffLineAdd", { bg = nord_utils.darken(nord_colors.aurora.green, 0, editor_bg) })
  vim.api.nvim_set_hl(0, "CodeDiffLineDelete", { bg = nord_utils.darken(nord_colors.aurora.red, 0, editor_bg) })
  vim.api.nvim_set_hl(0, "CodeDiffCharAdd", { bg = nord_utils.darken(nord_colors.aurora.green, 0.2, editor_bg) })
  vim.api.nvim_set_hl(0, "CodeDiffCharDelete", { bg = nord_utils.darken(nord_colors.aurora.red, 0.2, editor_bg) })
end

require("codediff").setup({
  highlights = {
    line_insert = "CodeDiffLineAdd",
    line_delete = "CodeDiffLineDelete",
    char_insert = "CodeDiffCharAdd",
    char_delete = "CodeDiffCharDelete",
  },
})

map("n", "<leader>gd", "<cmd>CodeDiff<cr>", { desc = "Review changes" })
map("n", "<leader>gh", "<cmd>CodeDiff history<cr>", { desc = "Git history" })

-------------------------------------------------------------------------------
-- Filepicker
-------------------------------------------------------------------------------

vim.pack.add({
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

local actions = require("telescope.actions")

require("telescope").setup({
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
    },
    file_ignore_patterns = { "%.git/" },
    mappings = {
      i = {
        -- Quit telescope on esc instead of entering normal mode
        ["<esc>"] = actions.close,
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
  },
})

-- Find a known file.
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", {
  desc = "Find files",
})
map("n", "<leader><space>", "<cmd>Telescope find_files<cr>", {
  desc = "Find files",
})

-- Search for text across the project.
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", {
  desc = "Search project",
})

-- Jump between already-open buffers.
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", {
  desc = "Find buffers",
})

-- Search Neovim's documentation.
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", {
  desc = "Search help",
})

-- A universal command palette. Telescope generates this from Neovim's
-- registered commands, so there is no manual command registry to maintain.
map("n", "<leader>fc", "<cmd>Telescope commands<cr>", {
  desc = "Command palette",
})

map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", {
  desc = "Diagnostics",
})

-- These override the bare built-in LSP implementations with Telescope
-- versions, because references/definitions are often more useful as a
-- navigable list than as a single jump.

map("n", "grd", "<cmd>Telescope lsp_definitions<cr>", {
  desc = "Go to definition",
})

map("n", "grr", "<cmd>Telescope lsp_references<cr>", {
  desc = "Find references",
})

map("n", "gri", "<cmd>Telescope lsp_implementations<cr>", {
  desc = "Find implementations",
})

map("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", {
  desc = "Document symbols",
})

map("n", "<leader>ws", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", {
  desc = "Workspace symbols",
})

-------------------------------------------------------------------------------
-- Statusline
-------------------------------------------------------------------------------

vim.pack.add({
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

require("lualine").setup({
  options = {
    theme = "nord",
  },
})

-------------------------------------------------------------------------------
-- Messages / notifications
-------------------------------------------------------------------------------

-- Renders cmdline, messages, and notifications as popups so nothing is lost
-- to cmdheight=0.
vim.pack.add({
  "https://github.com/folke/noice.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/rcarriga/nvim-notify",
})

require("noice").setup({
  presets = {
    bottom_search = true,
    long_message_to_split = true,
  },
})

-------------------------------------------------------------------------------
-- File tree
-------------------------------------------------------------------------------

vim.pack.add({
  {
    src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    version = vim.version.range("3"),
  },
  -- dependencies
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  -- optional, but recommended
  "https://github.com/nvim-tree/nvim-web-devicons",
})

require("neo-tree").setup({
  reveal = true,
  close_if_last_window = true,
  filesystem = {
    follow_current_file = {
      enabled = true,
      leave_dirs_open = true,
    },

    -- Prefer the project root when one is available.
    use_libuv_file_watcher = true,

    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },

  window = {
    width = 32,
    mappings = {
      ["e"] = function()
        require("neo-tree.sources.common.preview").hide()
        vim.api.nvim_exec2("Neotree focus filesystem left", {
          output = true,
        })
      end,
      ["b"] = function()
        require("neo-tree.sources.common.preview").hide()
        vim.api.nvim_exec2("Neotree focus buffers left", {
          output = true,
        })
      end,
      ["g"] = function()
        require("neo-tree.sources.common.preview").hide()
        vim.api.nvim_exec2("Neotree focus git_status left", {
          output = true,
        })
      end,
    },
  },
  event_handlers = {
    {
      -- Auto close neotree on open
      event = "file_open_requested",
      handler = function()
        require("neo-tree.command").execute({ action = "close" })
      end,
    },
    {
      -- Preview file under cursor. `after_render` fires for every source
      -- (filesystem/buffers/git_status), including ones re-rendering in the
      -- background while a different source is on screen, since they all
      -- share one window but keep separate buffers. Only auto-preview when
      -- this state's buffer is the one actually visible, otherwise the
      -- preview's cursor-tracking subscription binds to a hidden buffer and
      -- crashes on the next cursor move.
      event = "after_render",
      handler = function(state)
        if not (state.winid and vim.api.nvim_win_is_valid(state.winid)) then
          return
        end
        if vim.api.nvim_win_get_buf(state.winid) ~= state.bufnr then
          return
        end
        local preview = require("neo-tree.sources.common.preview")
        if not preview.is_active() then
          state.config = { use_float = false }
          state.commands.toggle_preview(state)
        end
      end,
    },
  },
})

map("n", "<leader>e", "<cmd>Neotree toggle<cr>", {
  desc = "File explorer",
})

-------------------------------------------------------------------------------
-- Completion
-------------------------------------------------------------------------------

vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = "v1" },
  "https://github.com/rafamadriz/friendly-snippets",
})

require("blink.cmp").setup({
  keymap = {
    preset = "super-tab",
  },
  completion = {
    list = {
      selection = {
        -- Don't preselect a completion item when a snippet is active, so
        -- <Tab> jumps to the next snippet placeholder instead of accepting it.
        preselect = function(ctx)
          return not require("blink.cmp").snippet_active({ direction = 1 })
        end,
      },
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
      autotrigger = true,
    })
  end,
})

vim.opt.completeopt = {
  "menu",
  "menuone",
  "noselect",
  "popup",
}

map("i", "<c-space>", function()
  vim.lsp.completion.get()
end)

-------------------------------------------------------------------------------
-- Formatting
-------------------------------------------------------------------------------

vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
})

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    rust = { "rustfmt" },
    javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
    typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
    json = { "biome", "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },
    python = { "ruff_format" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})

-------------------------------------------------------------------------------
-- Linting
-------------------------------------------------------------------------------

vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

local lint = require("lint")

vim.env.ESLINT_D_PPID = vim.fn.getpid()

lint.linters_by_ft = {
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  python = { "ruff" },
  lua = { "luacheck" },
}

-- Lint when entering a buffer, after saving, and after leaving insert mode.
-- This gives useful feedback without continuously running linters on every
-- keystroke.
vim.api.nvim_create_autocmd({
  "BufEnter",
  "BufWritePost",
  "InsertLeave",
}, {
  callback = function()
    lint.try_lint()
  end,
})

-------------------------------------------------------------------------------
-- Neovim Configuration
-------------------------------------------------------------------------------

-- Automatically reload neovim on config update
local group = vim.api.nvim_create_augroup("MyVimrcAutoReload", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "init.lua" },
  group = group,
  callback = function()
    vim.cmd("source " .. vim.fn.stdpath("config") .. "/init.lua")
  end,
})

-------------------------------------------------------------------------------
-- TMUX integration
-------------------------------------------------------------------------------

-- Move between and among vim and tmux splits with Ctrl+h/j/k/l
vim.pack.add({
  "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/tmux-plugins/vim-tmux-focus-events",
  "https://github.com/tmux-plugins/vim-tmux",
})

-------------------------------------------------------------------------------
-- Auto pairs
-------------------------------------------------------------------------------

vim.pack.add({
  "https://github.com/windwp/nvim-autopairs",
})

require("nvim-autopairs").setup({})

-------------------------------------------------------------------------------
-- Colorize color literals
-------------------------------------------------------------------------------

vim.pack.add({ "https://github.com/brenoprata10/nvim-highlight-colors" })
require("nvim-highlight-colors").setup({})

-------------------------------------------------------------------------------
-- Diagnostics
-------------------------------------------------------------------------------

vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
})

-------------------------------------------------------------------------------
-- Animation
-------------------------------------------------------------------------------

-- Smooth scroll
vim.pack.add({ "https://github.com/karb94/neoscroll.nvim" })

require("neoscroll").setup({
  duration_multiplier = 0.6,
  easing = "quadratic",
})

-- Smooth cursor movements
vim.pack.add({ "https://github.com/sphamba/smear-cursor.nvim" })

require("smear_cursor").setup({
  stiffness = 0.7,
  trailing_stiffness = 0.7,
  matrix_pixel_threshold = 0.7,
  distance_stop_animating = 0.7,
  never_draw_over_target = false,
  legacy_computing_symbols_support = true,
})

-------------------------------------------------------------------------------
-- Quick jump
-------------------------------------------------------------------------------

vim.pack.add({
  "https://github.com/folke/flash.nvim",
})

-- require("flash").setup()

-- map({ "n", "x", "o" }, "s", function()
--   require("flash").jump()
-- end, { desc = "Flash" })

vim.o.langmap = "ö[,ä]"

vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.nvim', version = 'stable' },
})

require('mini.comment').setup()
require('mini.surround').setup()

-------------------------------------------------------------------------------
-- Quick jump
-------------------------------------------------------------------------------

vim.pack.add({
    { src = "https://github.com/Isrothy/neominimap.nvim" },
})

-- The following options are recommended when layout == "float"
vim.opt.wrap = false
vim.opt.sidescrolloff = 36 -- Set a large value

--- Put your configuration here
---@type Neominimap.UserConfig
vim.g.neominimap = {
    auto_enable = true,
    float = {
        minimap_width = 12,
    },
}
