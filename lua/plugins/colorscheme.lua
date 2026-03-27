return {
	{
		"shaunsingh/oxocarbon.nvim",
		name = "oxocarbon",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme oxocarbon]])
		end,
	},
}
