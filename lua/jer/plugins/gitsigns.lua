-- gitsigns.nvim default installation
-- Place this file in your Neovim config (e.g. ~/.config/nvim/lua/plugins/gitsigns.lua
-- if using lazy.nvim's plugin spec convention, or require() it from init.lua)

return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup()
  end,
}
