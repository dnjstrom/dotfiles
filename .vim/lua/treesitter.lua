require'nvim-treesitter.configs'.setup {
  ensure_installed = "bash c clojure comment css dockerfile elm fish go graphql haskell help hjson html http java javascript jsdoc json json5 jsonc kotlin latex lua make markdown nix pug python regex ruby rust svelte todotxt tsx typescript vim vue",
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true
  }
}
