return {
	'LukasPietzschmann/telescope-tabs',
	config = function()
		require('telescope').load_extension 'telescope-tabs'
		require('telescope-tabs').setup {
		entry_formatter = function(tab_id, buffer_ids, file_names, file_paths, is_current)
    		if vim.g.Tabline_session_data == nil then
      			return
    		end
    		local TablineData = vim.fn.json_decode(vim.g.Tabline_session_data)

    		local function find_tabpage_index(tab_id)
      		local tabpages = vim.api.nvim_list_tabpages()
      		for index, tp in ipairs(tabpages) do
        		if tp == tab_id then
          			return index
        		end
      		end
      		return nil
    		end
    		local status_ok, tabpage_id = pcall(find_tabpage_index, tab_id)
    		if not status_ok then
      			print("telescope-tabs Error : or Not found correctly tab_id in nvim tab list")
      			return
    		end

    		local tab_name = TablineData[tabpage_id].name
    		-- require("tabby.feature.tab_name").get(tab_id)
    		-- return string.format("%d: %s%s", tab_id, tab_id, is_current and " <" or "")

    		-- Get the focused window's buffer ID for the current tab
    		local focused_win = vim.fn.tabpagewinnr(tabpage_id)

    		-- Iterate over file_names and add '<' if the corresponding buffer exists
    		file_names[focused_win] = file_names[focused_win] .. " #"

    		local entry_string = table.concat(file_names, ', ')
    		return string.format('%d [%s]: %s%s', tabpage_id, tab_name, entry_string, is_current and ' <' or '')
  		end,
  		entry_ordinal = function(tab_id, buffer_ids, file_names, file_paths, is_current)
    		-- return table.concat(file_names, ' ')
    		if vim.g.Tabline_session_data == nil then
      			return
    		end
    		local TablineData = vim.fn.json_decode(vim.g.Tabline_session_data)
    		-- need require "user.tabpage" in config.lua
    		local status_ok, tabpage_id = pcall(find_tabpage_index, tab_id)
    		if not status_ok then
      			return
    		end

    		-- return TablineData[tab_id].name
    		local entry_string = table.concat(file_names, ', ')
    		return string.format('%d %s %s', tabpage_id, TablineData[tabpage_id].name, entry_string)
    		-- require("tabby.feature.tab_name").get(tab_id)
  		end
		}
	end,
	dependencies = { 'nvim-telescope/telescope.nvim' },
}
