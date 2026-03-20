return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon", -- Puedes probar "storm", "moon" o "night"
      transparent = true, -- ESTO ES CLAVE para que herede el fondo de tu terminal
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
