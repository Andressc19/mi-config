return {
  {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      require("themery").setup({
        themes = {
          "catppuccin",
          "kanagawa",
          "oldworld",
        },
        livePreview = true,
      })
    end,
  },
}
