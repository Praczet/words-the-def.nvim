local M = {}

local Job = require("plenary.job")

-- Fetch data from the API and process it safely
function M.fetch_data(url, callback)
	Job:new({
		command = "curl",
		args = { "-s", url }, -- Output to temp file
		on_exit = function(j, return_val)
			if return_val == 0 then
				-- Read the file outside the callback
				vim.schedule(function()
					callback(j:result())
				end)
			else
				print("Error fetching data from the API")
			end
		end,
	}):start()
end

-- Show results in a floating window and set the buffer filetype to Markdown
function M.show_in_floating_window(lines)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

	-- Set buffer filetype to Markdown using vim.bo
	vim.bo[bufnr].filetype = "markdown"
	-- vim.bo[bufnr].wrap = true

	local width = vim.o.columns
	local height = vim.o.lines
	local win_width = math.ceil(width * 0.9)
	local win_height = math.ceil(height * 0.7)
	local row = math.ceil((height - win_height) / 2)
	local col = math.ceil((width - win_width) / 2)

	local win_id = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})
	vim.api.nvim_set_option_value("wrap", true, { win = win_id })

	-- Close the floating window with <Esc>
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<Cmd>bd!<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd>bd!<CR>", { noremap = true, silent = true })
end

return M
