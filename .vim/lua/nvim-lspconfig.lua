vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  signs = true,
})

vim.cmd [[autocmd CursorHold * Lspsaga show_cursor_diagnostics]]
vim.cmd [[autocmd CursorHoldI * silent! Lspsaga show_cursor_diagnostics]]
vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]

local on_attach = function(client, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.cmd("command! LspFormatting lua vim.lsp.buf.format()")

  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<leader>rn', '<cmd>Lspsaga rename<cr>', opts)
  vim.keymap.set('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', opts)
  vim.keymap.set('v', '<leader>ca', ':<C-U>Lspsaga range_code_action<CR>', opts)
  vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<cr>', opts)
  vim.keymap.set('n', 'gj', '<cmd>Lspsaga diagnostic_jump_next<cr>', opts)
  vim.keymap.set('n', 'gk', '<cmd>Lspsaga diagnostic_jump_prev<cr>', opts)

  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      command = 'LspFormatting',
    })
  end
end

vim.lsp.config('rust_analyzer', { on_attach = on_attach })
vim.lsp.enable('rust_analyzer')

local organize_imports_sync = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(0)
  local params = {
    command = "_typescript.organizeImports",
    arguments = { name },
    title = ""
  }
  vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", params, 500)
end

vim.lsp.config('ts_ls', {
  init_options = {
    preferences = {
      importModuleSpecifierPreference = "relative"
    }
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    on_attach(client, bufnr)
  end,
  commands = {
    LspOrganizeImports = {
      organize_imports_sync,
      description = "Organize imports (synchronously)"
    }
  }
})
vim.lsp.enable('ts_ls')

local linters = {
  eslint = {
    sourceName = "eslint",
    command = "eslint_d",
    rootPatterns = { ".eslintrc.js", "package.json" },
    debounce = 100,
    args = { "--stdin", "--stdin-filename", "%filepath", "--format", "json" },
    parseJson = {
      errorsRoot = "[0].messages",
      line = "line",
      column = "column",
      endLine = "endLine",
      endColumn = "endColumn",
      message = "${message} [${ruleId}]",
      security = "severity"
    },
    securities = { [2] = "error", [1] = "warning" }
  },
  stylelint = {
    sourceName = "stylelint",
    command = "stylelint_d",
    rootPatterns = { ".stylelintrc.js", "package.json" },
    debounce = 100,
    args = { "--stdin", "--stdin-filename", "%filepath", "--formatter", "json" },
    parseJson = {
      errorsRoot = "[0].warnings",
      line = "line",
      column = "column",
      message = "${text}",
      security = "severity"
    },
    securities = { error = "error", warning = "warning" }
  },
}

local filetypes = {
  typescript = "eslint",
  typescriptreact = "eslint",
  css = "stylelint",
  scss = "stylelint",
}

local formatters = {
  eslint = { command = "eslint_d ", args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "%filename" } },
  stylelint = { command = "stylelint_d ", args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "%filename" } },
  prettier = { command = "prettier_d_slim", args = { "--stdin", "--stdin-filepath", "%filepath" } }
}

local formatFiletypes = {
  javascript = "prettier",
  javascriptreact = "prettier",
  typescript = "prettier",
  typescriptreact = "prettier",
  json = "prettier",
  css = "prettier",
  scss = "prettier",
  html = "prettier",
  yaml = "prettier",
  markdown = "prettier"
}

vim.lsp.config('diagnosticls', {
  on_attach = on_attach,
  filetypes = vim.tbl_keys(formatFiletypes),
  init_options = {
    filetypes = filetypes,
    linters = linters,
    formatters = formatters,
    formatFiletypes = formatFiletypes
  }
})
vim.lsp.enable('diagnosticls')
