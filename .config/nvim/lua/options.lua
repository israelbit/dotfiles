vim.opt.number = true
vim.lsp.enable({'ast-grep','clangd','marksman','html','dockerls','docker_compose'})
vim.opt.termguicolors = true

return {
	cmp = { 
		keymap = require("keymaps").cmp,
		appearance = {
			nerd_font_variant = 'mono'
		},
		completion = { documentation = { 
			auto_show = true,
			auto_show_delay_ms = 500,
	}, 
	},
},
}


