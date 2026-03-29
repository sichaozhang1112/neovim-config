return {
	-- nvim tree sitter
	{
		"nvim-treesitter/nvim-treesitter",
		enabled = false,
		build = ":TSUpdate",
		config = function()
			local parser_install_dir = vim.fn.stdpath("data") .. "/site"

			require("nvim-treesitter.configs").setup({
                -- A list of parser names, or "all" (the listed parsers should always be installed).
                -- Expand this list to include commonly-used languages. If you prefer a smaller set,
                -- edit this list or set to "all" and use `ignore_install`.
                ensure_installed = {
                    "c",
                    "lua",
                    "vim",
                    "cpp",
                    "python",
                    -- Common web / markup
                    "html",
                    "css",
                    "javascript",
                    "typescript",
                    "tsx",
                    "vue",
                    "svelte",
                    -- docs/math/latex
                    "latex",
                    "typst",
                    -- styles
                    "scss",
                    -- note: add other languages you work with here
                },

				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have the `tree-sitter` CLI installed locally
                auto_install = false,

				-- Parser install dir must be on runtimepath.
				parser_install_dir = parser_install_dir,

                -- List of parsers to ignore installing (for "all")
                ignore_install = {},

				---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
				-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

				highlight = {
					enable = true,

					-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
					-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
					-- the name of the parser)
					-- list of language that will be disabled
					disable = { "c", "rust" },
					-- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
					disable = function(lang, buf)
						local max_filesize = 100 * 1024 -- 100 KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,

					-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
					-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
					-- Using this option may slow down your editor, and you may see some duplicate highlights.
					-- Instead of true it can also be a list of languages
					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},
}
