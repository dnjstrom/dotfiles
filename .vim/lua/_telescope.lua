local M = {}

local actions = require('telescope.actions')

require('telescope').setup {
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      "__image_snapshots__",
      "__gql_types__"
    },
    mappings = {
      i = {
        ["<esc>"] = actions.close, -- Close on single <esc>
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}

-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')


-- Fall back to find_files if we're not in a git repo
M.project_files = function()
  local opts = {} -- define here if you want to define something
  local ok = pcall(require'telescope.builtin'.git_files, opts)
  if not ok then require'telescope.builtin'.find_files(opts) end
end


vim.api.nvim_set_keymap("n", "<C-p>", "<CMD>lua require\'_telescope\'.project_files()<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader><space>", ":Telescope lsp_document_symbols <CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "gr", ":Telescope lsp_references <CR>", { silent = true, noremap = true })

-- nnoremap <leader>ff <cmd>Telescope find_files<cr>
-- nnoremap <leader>fg <cmd>Telescope live_grep<cr>
-- nnoremap <leader>fb <cmd>Telescope buffers<cr>
-- nnoremap <leader>fh <cmd>Telescope help_tags<cr>

vim.cmd("command! Find :Telescope live_grep")

return M
