vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/plugged/nvim-treesitter/runtime')

require('nvim-treesitter').setup({
  ensure_installed = {
    "bash", "c", "clojure", "css", "dockerfile", "elm", "fish",
    "go", "graphql", "haskell", "hjson", "html", "http", "java",
    "javascript", "jsdoc", "json", "json5", "jsonc", "kotlin", "latex",
    "lua", "make", "markdown", "nix", "pug", "python", "regex",
    "ruby", "rust", "svelte", "tsx", "typescript", "vim", "vue"
  },
  auto_install = true,
})

-- Enable built-in treesitter highlighting for all buffers
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Textobject keymaps via nvim-treesitter-textobjects
local select = require('nvim-treesitter-textobjects.select')

local keymaps = {
  af = { query = "@function.outer" },
  ["if"] = { query = "@function.inner" },
  ac = { query = "@class.outer" },
  ic = { query = "@class.inner" },
  as = { query = "@local.scope", query_group = "locals" },
}

for key, opts in pairs(keymaps) do
  vim.keymap.set({ "x", "o" }, key, function()
    select.select_textobject(opts.query, opts.query_group or "textobjects")
  end, { desc = "Treesitter select " .. opts.query })
end

require('nvim-treesitter-textobjects').setup({
  select = {
    lookahead = true,
    selection_modes = {
      ["@parameter.outer"] = "v",
      ["@function.outer"] = "V",
      ["@class.outer"] = "<c-v>",
    },
    include_surrounding_whitespace = false,
  },
})
