local M = {}
M.config = {}

local function check_plenary()
	local status_ok, plenary = pcall(require, "plenary")
	if not status_ok then
		vim.api.nvim_err_writeln("Plenary.nvim is not installed. Please install it to use this plugin.")
		return false
	end
	return true
end

if not check_plenary() then
	return
end

local utils = require("words-the-def.utils")

local pos_map = {
	n = "noun",
	v = "verb",
	adj = "adjective",
	adv = "adverb",
	pron = "pronoun",
	prep = "preposition",
	conj = "conjunction",
	det = "determiner",
	num = "numeral",
	int = "interjection",
}
local datamuse_code_map = {
	jja = '"Popular nouns modified by the given adjective, per Google Books Ngrams"',
	jjb = '"Popular adjectives used to modify the given noun, per Google Books Ngrams"',
	syn = '"Synonyms (words contained within the same WordNet synset)"',
	trg = '"Triggers (words that are statistically associated with the query word in the same piece of text)"',
	ant = '"Antonyms (per WordNet)"',
	spc = '"Kind of (direct hypernyms, per WordNet)"',
	gen = '"More general than (direct hyponyms, per WordNet)"',
	com = '"Comprises (direct holonyms, per WordNet)"',
	par = '"Part of (direct meronyms, per WordNet)"',
	bga = '"Frequent followers (per Google Books Ngrams)"',
	bgb = '"Frequent predecessors (per Google Books Ngrams)"',
	hom = '"Homophones (sound-alike words)"',
	cns = '"Consonant match"',
}
-- Thesaurus command
local function thesaurus(word, code)
	code = string.lower(code)
	local url = "https://api.datamuse.com/words?rel_" .. code .. "=" .. word
	utils.fetch_data(url, function(result)
		result = vim.fn.json_decode(result)
		if #result > 0 then
			local words = {}
			local def = datamuse_code_map[code]
			if def then
				table.insert(words, "# " .. def .. " for word: `" .. word .. "`")
			else
				table.insert(words, "# " .. word)
			end
			table.insert(words, "")
			for _, line in ipairs(result) do
				table.insert(words, "- " .. line.word)
			end
			utils.show_in_floating_window(words)
		else
			vim.notify("No results found for '" .. word .. "' with code '" .. code .. "'", vim.log.levels.WARN)
		end
	end)
end

-- Function to format the definition lines
local function format_definition_line(line)
	-- Match the part of speech (e.g., "n", "v", "adj")
	local pos_abbr, definition = line:match("^(%a+)%s*(.*)")
	if pos_abbr and definition then
		-- Convert abbreviation to full form and enclose in asterisks
		local full_pos = pos_map[pos_abbr]
		if full_pos then
			return string.format("*(%s)* %s", full_pos, definition)
		end
	end
	return line -- Return the original line if no match
end

-- Definition command
local function definition(word)
	local url = "https://api.datamuse.com/words?sp=" .. word .. "&md=d"
	utils.fetch_data(url, function(result)
		result = vim.fn.json_decode(result)
		if #result > 0 then
			local definitions = {}
			table.insert(definitions, "# Definitions for:")
			table.insert(definitions, "")
			for upper_index, item in ipairs(result) do
				if item.defs then
					table.insert(definitions, "")
					table.insert(definitions, "## (" .. upper_index .. ") " .. (item.word or "~error~"))
					table.insert(definitions, "")
					for index, def in ipairs(item.defs) do
						table.insert(definitions, tostring(index) .. ". " .. format_definition_line(def))
					end
				end
			end
			if #definitions > 0 then
				utils.show_in_floating_window(definitions)
			else
				vim.notify("No definitions found for '" .. word .. "'", vim.log.levels.INFO)
			end
		else
			vim.notify("No results found for '" .. word .. "'", vim.log.levels.WARN)
		end
	end)
end

local function show_word_definition(word)
	-- Run the `dict` command and capture the output
	local handle = io.popen("dict " .. word)
	local result
	if handle then
		result = handle:read("*a")
		handle:close()
	else
		vim.notify("Could not run `dict`", vim.log.levels.ERROR)
		return
	end

	-- Create a floating window to display the result
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(result, "\n"))

	local width = vim.o.columns
	local height = vim.o.lines
	local win_width = math.ceil(width * 0.8)
	local win_height = math.ceil(height * 0.6)
	local row = math.ceil((height - win_height) / 2)
	local col = math.ceil((width - win_width) / 2)

	vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<Cmd>bd!<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd>bd!<CR>", { noremap = true, silent = true })
end

local function setup_commands()
	-- Register commands
	vim.api.nvim_create_user_command("WordThesaurus", function(opts)
		local word = opts.fargs[1]
		local code = opts.fargs[2] or "syn" -- Default code is 'syn' for synonyms
		thesaurus(word, code)
	end, { nargs = "*" })

	vim.api.nvim_create_user_command("WordDefinition", function(opts)
		definition(opts.args)
	end, { nargs = 1 })

	vim.api.nvim_create_user_command("WordDict", function(opts)
		show_word_definition(opts.args)
	end, { nargs = 1 })
end

local function setup_keymaps()
	require("which-key").add({
		{ "<leader>W", group = "Words Thesaurus Definition" },
		{
			"<leader>Wt",
			function()
				thesaurus(vim.fn.expand("<cword>"), "syn")
			end,
			desc = "Show Word Thesaurus",
		},
		{
			"<leader>Wd",
			function()
				definition(vim.fn.expand("<cword>"))
			end,
			desc = "Show Word Definition",
		},
		{
			"<leader>Wl",
			function()
				show_word_definition(vim.fn.expand("<cword>"))
			end,
			desc = "Show Word Definition using dict",
		},
	})
end

function M.setup(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})
	setup_commands()
	setup_keymaps()
end
return M
