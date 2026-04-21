return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    { "kevinhwang91/promise-async" },
  },
  event = "BufReadPost",
  opts = {
    provider_selector = function(bufnr, filetype, buftype)
      return { "treesitter", "indent" }
    end,
  },
  init = function()
    -- These MUST be set before the plugin loads
    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99  -- High value = all folds open by default
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,
}

