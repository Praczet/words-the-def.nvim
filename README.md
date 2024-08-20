# Words Thesaurus Definition

**Words-the-Def.nvim** is a Neovim plugin that integrates word lookup capabilities
directly into your editor. It allows you to fetch and display definitions,
synonyms, and other linguistic data for words under your cursor
or specified by commands. The results are shown in a floating window,
enhancing your writing and editing workflow.

## Features

- Fetch synonyms using the `:WordThesaurus` command or key mapping.
- Retrieve word definitions with the `:WordDefinition` command or key mapping.
- Retrieve word definitions with the `:WordDict` command or key mapping.
- Easily extendable to support additional linguistic data.

## Installation

### Using [vim-plug](https://github.com/junegunn/vim-plug)

Add the following to your `init.vim` or `init.lua` file:

```vim
Plug 'nvim-lua/plenary.nvim'  " Required dependency
Plug 'Praczet/words-the-def.nvim'
```

Then, run `:PlugInstall` to install the plugin.

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

Add the following to your `init.lua` file:

```lua
use {
    'Praczet/words-the-def.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
}
```

### Using lazy.nvim

```lua
  {
    "Praczet/words-the-def.nvim",
    config = function()
      require("words-the-def").setup({})
    end,
  },
```

Then, run `:PackerSync` to install the plugin.

## Requirements

- Neovim 0.5.0 or later
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) plugin
- [which-key.nvim](https://github.com/folke/which-key.nvim) (optional, for keybinding hints)

## Configuration

The plugin can be configured by calling the `setup` function in your `init.lua`:

```lua
require('words-the-def').setup({
  -- Your configuration options here
})
```

## Commands

- `:WordThesaurus <word> [code]`: Fetch synonyms for the given word. The `code` parameter is optional and defaults to "syn" (synonyms).
- `:WordDefinition <word>`: Fetch the definition of the given word.
- `:WordDict <word>`: Fetch the definition using a `dict` command (I think for
  Linux only).

### Available `code` Parameters for `:WordThesaurus`

The `:WordThesaurus` command uses a second optional parameter, `code`, which determines the type of linguistic data retrieved. Below are the available options:

- **`syn`**: Synonyms (words contained within the same WordNet synset).
- **`ant`**: Antonyms (words with opposite meanings, per WordNet).
- **`trg`**: Triggers (words that are statistically associated with the query word in the same piece of text).
- **`spc`**: "Kind of" (words that are more specific than the query word).
- **`gen`**: "More general" (words that are more general than the query word).
- **`com`**: "Comprises" (words that constitute parts of the query word).
- **`par`**: "Part of" (words that the query word is a part of).
- **`bga`**: "Frequent followers" (words that frequently follow the query word in text).
- **`bgb`**: "Frequent predecessors" (words that frequently precede the query word in text).
- **`rhy`**: Rhymes (words that rhyme with the query word).
- **`nry`**: Approximate rhymes (words that nearly rhyme with the query word).
- **`hom`**: Homophones (words that sound like the query word).
- **`cns`**: Consonant match (words that have a similar consonant structure).

## Key Mappings

The plugin also provides default key mappings for quick access:

- `<leader>Wt`: Show synonyms for the word under the cursor.
- `<leader>Wd`: Show the definition of the word under the cursor.
- `<leader>Wl`: Show the definition using a specific dictionary for the word under the cursor.

These key mappings can be customized by adjusting the `setup_keymaps` function or by overriding them in your configuration.

## Usage

- Use the provided commands in command mode to fetch and display linguistic data.
- Use the key mappings to quickly look up words under your cursor.

## Acknowledgments

Special thanks to [api.datamuse.com](https://api.datamuse.com) for providing the
linguistic data that powers this plugin. The service offers a wealth
of word-related information, and this plugin wouldn't be possible without it.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests to improve the plugin.

## License

This plugin is licensed under the MIT License. See [LICENSE](./LICENSE) for more details.
