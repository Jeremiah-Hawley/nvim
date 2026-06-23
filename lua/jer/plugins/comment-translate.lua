return {
  'noir4y/comment-translate.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('comment-translate').setup({
	target_language = 'en',
  	translate_service = 'google', -- 'google' or 'llm'

  	hover = {
    	enabled = true,
    	delay = 500,
    	auto = true,
  	},

  	immersive = {
    	enabled = false,
  	},

  	cache = {
    	kenabled = true,
    	max_entries = 1000,
  	},

  	targets = {
    	comment = true,
    	string = true,
  	},
    })
  end,
}
