return {
  {
    'codota/tabnine-nvim', 
    build = "./dl_binaries.sh",
    config = function()
      -- this is where tabnine configs go
      vim.g.tabine_maximum_results = 10
      require('tabnine').setup({
        disable_auto_comment = true,
        accespt_keymap = "<Tab>",
        dismiss_keymap = "<C-]",
        debounce_ms = 800,
        suggestion_color = { gui = "#808080", cterm = 244},
        exclude_filetypes = {"TelescopePrompp", "NvimTree"},
        log_file_path = nil,
        ignore_certificate_errors = false,
      })
    end
  }
}
