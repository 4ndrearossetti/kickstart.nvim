-- lua/custom/plugins/init.lua
-- =============================================================================
--  Custom plugins — Andrea Rossetti
--
--  Auto-imported by kickstart via  { import = 'custom.plugins' }.
--  Returns a lazy.nvim spec list.
--    1. toggleterm — in-editor terminals (project-root + file-dir)
--    2. neogit     — Magit-style full git UI  (+ diffview for rich diffs)
-- =============================================================================

return {

  -- ===========================================================================
  --  toggleterm.nvim — persistent, toggleable terminals inside Neovim
  -- ===========================================================================
  {
    'akinsho/toggleterm.nvim',
    version = '*', -- track the latest TAGGED release
    opts = {
      -- Ctrl-\ toggles the last-used terminal from normal AND terminal mode.
      -- Rooted at nvim's working directory (your project root).
      open_mapping = [[<c-\>]],
      direction = 'float',
      float_opts = { border = 'curved' },
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return math.floor(vim.o.columns * 0.4)
        end
      end,
      shade_terminals = true,
      start_in_insert = true,
      persist_mode = false,
    },

    config = function(_, opts)
      require('toggleterm').setup(opts)

      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add { { '<leader>t', group = '[T]erminal' } }
      end

      vim.keymap.set('n', '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', { desc = '[T]erminal [F]loat' })
      vim.keymap.set('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', { desc = '[T]erminal [H]orizontal' })
      vim.keymap.set('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', { desc = '[T]erminal [V]ertical' })

      -- <leader>td — dedicated terminal that cd's to the CURRENT FILE's dir.
      local Terminal = require('toggleterm.terminal').Terminal
      local file_term = nil
      vim.keymap.set('n', '<leader>td', function()
        local dir = vim.fn.expand '%:p:h'
        file_term = file_term or Terminal:new { direction = 'float' }
        if file_term:is_open() then
          file_term:close()
        else
          file_term:open()
          file_term:send('cd ' .. vim.fn.fnameescape(dir), false)
        end
      end, { desc = '[T]erminal in file [D]ir' })

      vim.api.nvim_create_autocmd('TermOpen', {
        pattern = 'term://*',
        callback = function()
          vim.keymap.set('t', '<esc><esc>', [[<C-\><C-n>]], { buffer = 0 })
        end,
      })
    end,
  },

  -- ===========================================================================
  --  neogit — a Magit-style git interface: the whole repo as one navigable,
  --  foldable status buffer. Stage/unstage by file/hunk/line, commit in a real
  --  buffer, push/pull/rebase/stash — all keyboard-driven from one screen.
  --  Pairs WITH your existing gitsigns (gutter signs / inline hunks), it does
  --  not replace it.
  -- ===========================================================================
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required (you already have it via telescope)
      'sindrets/diffview.nvim', -- rich side-by-side diffs + file history
      'nvim-telescope/telescope.nvim', -- use telescope for neogit's pickers
    },
    -- Lazy-load on the commands + the keymaps below.
    cmd = { 'Neogit' },
    keys = {
      {
        '<leader>gg',
        function()
          require('neogit').open()
        end,
        desc = '[G]it: Neo[g]it status',
      },
      {
        '<leader>gc',
        function()
          require('neogit').open { 'commit' }
        end,
        desc = '[G]it: [C]ommit',
      },
      {
        '<leader>gp',
        function()
          require('neogit').open { 'pull' }
        end,
        desc = '[G]it: [P]ull',
      },
      {
        '<leader>gP',
        function()
          require('neogit').open { 'push' }
        end,
        desc = '[G]it: [P]ush',
      },
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = '[G]it: [D]iff view' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = '[G]it: file [H]istory' },
    },
    opts = {
      integrations = {
        telescope = true,
        diffview = true,
      },
    },
    config = function(_, opts)
      require('neogit').setup(opts)
      -- which-key group label for the <leader>g cluster.
      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add { { '<leader>g', group = '[G]it' } }
      end
    end,
  },
}
