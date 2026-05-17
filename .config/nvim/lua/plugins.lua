        -- Bootstrap lazy.nvim
        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not (vim.uv or vim.loop).fs_stat(lazypath) then
          local lazyrepo = "https://github.com/folke/lazy.nvim.git"
          local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
          if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
              { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
              { out, "WarningMsg" },
              { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
          end
        end
        vim.opt.rtp:prepend(lazypath)


        -- setup lazy.nvim
        require("lazy").setup({

        -- baixar plugins
        spec = {
                {
                        "obsidian-nvim/obsidian.nvim",
                        dependencies = {"nvim-telescope/telescope.nvim"},
                        version = "*",
                        opts = {
                                legacy_commands = false,
                                workspaces = {
                                        {
                                                name = "personal",
                                                path = "~/vaults/personal",
                                        },
                                        {
                                                name = "hacking",
                                                path = "~/vaults/hacking",
                                        },
                                        {
                                                name = "faculdade",
                                                path = "~/vaults/estudos",
                                        },
                                },
                        },
                },
                {
                        'nvim-lualine/lualine.nvim',
                        dependencies = {'nvim-tree/nvim-web-devicons'}
                },

                {
                        "rebelot/kanagawa.nvim",
                },

                {
                        "saghen/blink.cmp",
                        version = '1.*',
                        opts = {
                                completion = {
                                        documentation = {auto_show = true},
                                        ghost_text = {enabled = true},
                                },
                                sources = {
                                        default = {'lsp','path','snippets','buffer'},
                                },
                                keymap = {
                                        preset = 'default',
                                        ['<CR>'] = {'select_and_accept','fallback'},
                                        ['Up'] = {'select_prev','fallback'},
                                        ['Down'] = {'select_next','fallback'},
                                },
                        },
                },

                {
                        "mason-org/mason-lspconfig.nvim",
                        opts = {
                                        ensure_installed = {
                                                "lua_ls",
                                                "rust_analyzer",
                                                "pyright",
                                                "marksman",
                                                "ts_ls",
                                                "html"
                                        }
                        },
                        dependencies = {
                                { "mason-org/mason.nvim", opts = {} },
                                "neovim/nvim-lspconfig",
                        }
                },

                {
                        "lukas-reineke/indent-blankline.nvim",
                        main = "ibl",
			opts = {},
                },
                {
                        "MeanderingProgrammer/render-markdown.nvim",
                        completions = {lsp = {enabled = true}},
                        opts = {code = {enabled =true,
                                        },
                        },

                },
                {
                        "nvim-treesitter/nvim-treesitter",
                        build = ":TSUpdate",
                        opts = {
                                ensure_installed = {
                                        "markdown",
                                        "markdown_inline",
                                        "html",
                                        "css",
                                        "javascript",
                                        "lua",
                                        "bash",
                                },
                                highlight = {
                                        enable = true,
                                },
                        },
                },

        },


        -- checagem de funcionamento de plugins
        checker ={enabled = true},
        })
        vim.cmd("colorscheme kanagawa")
	require('lualine').setup()
