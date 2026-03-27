return {
	{
		"NickvanDyke/opencode.nvim",
		dependencies = {
			-- Recommended for `ask()` and `select()`.
			-- Required for `snacks` provider.
			---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
			{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
		},
		config = function()
			---@type opencode.Opts
			vim.g.opencode_opts = {
				-- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
			}

			-- Required for `opts.events.reload`.
			vim.o.autoread = true

			-- Recommended/example keymaps.
			vim.keymap.set({ "n", "x" }, "<C-a>", function()
				require("opencode").ask("@this: ", { submit = true })
			end, { desc = "Ask opencode…" })
			vim.keymap.set({ "n", "x" }, "<C-x>", function()
				require("opencode").select()
			end, { desc = "Execute opencode action…" })
			local toggle_opencode = function()
				require("opencode").toggle()
			end
			for _, key in ipairs({ "<C-_>", "<C-/>" }) do
				vim.keymap.set({ "n", "t" }, key, toggle_opencode, { desc = "Toggle opencode" })
			end

			vim.keymap.set({ "n", "x" }, "go", function()
				return require("opencode").operator("@this ")
			end, { desc = "Add range to opencode", expr = true })
			vim.keymap.set("n", "goo", function()
				return require("opencode").operator("@this ") .. "_"
			end, { desc = "Add line to opencode", expr = true })

			vim.keymap.set("n", "<S-C-u>", function()
				require("opencode").command("session.half.page.up")
			end, { desc = "Scroll opencode up" })
			vim.keymap.set("n", "<S-C-d>", function()
				require("opencode").command("session.half.page.down")
			end, { desc = "Scroll opencode down" })

			-- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
			vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
			vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })

			-- Ensure opencode is closed/cleaned up when exiting Neovim (prevents "job is running" on :qa/:xa)
			local aug = vim.api.nvim_create_augroup("OpencodeAutoClose", { clear = true })
			vim.api.nvim_create_autocmd("VimLeavePre", {
				group = aug,
		callback = function()
			local events_ok, events = pcall(require, "opencode.events")
			if not events_ok or not events.connected_server then
				return
			end

			local ok, opencode = pcall(require, "opencode")
			if not ok or type(opencode) ~= "table" then
				return
			end

					-- Helper to safely call functions on the module if they exist.
					-- Accept either a function reference or a key name on the module.
					local function try_call(fn_or_name, ...)
						local fn = fn_or_name
						if type(fn_or_name) == "string" then
							fn = opencode[fn_or_name]
						end
						if type(fn) == "function" then
							-- pcall to avoid surfacing plugin errors during exit
							pcall(fn, ...)
							return true
						end
						return false
					end

					-- pcall wrapper that suppresses noisy errors that can occur during
					-- Neovim shutdown (e.g. jobs still running or missing autocommands).
					local function safe_pcall(fn, ...)
						local ok, res = pcall(fn, ...)
						if ok then
							return true, res
						end
						local msg = tostring(res or "")
						-- Ignore known, non-actionable errors during exit.
						if msg:match("E948") or msg:match("E676") then
							return false, nil
						end
						-- Log other errors at DEBUG level so they don't disturb exit.
						vim.notify("opencode cleanup error: " .. msg, vim.log.levels.DEBUG, { title = "opencode" })
						return false, nil
					end

					-- Try common cleanup APIs/operators/plugins may expose.
					-- Prefer explicit session commands (used elsewhere in this config).
					safe_pcall(try_call, opencode.command, "session.close")
					safe_pcall(try_call, opencode.command, "session.stop")
					safe_pcall(try_call, opencode.command, "session.quit")
					-- Try direct module functions if available.
					safe_pcall(try_call, "close")
					safe_pcall(try_call, "stop")
					safe_pcall(try_call, "shutdown")
					safe_pcall(try_call, "kill")
				end,
			})
		end,
	},
}
