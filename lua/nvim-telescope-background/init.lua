local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local function setup(params)
end

local M = {}

M.jobs = {}
M.job_id = 1

local function start_job(cmd)
  local job_id
  job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data then
        M.jobs[job_id].output = (M.jobs[job_id].output or "") .. table.concat(data, "\n") .. "\n"
      end
    end,
    on_exit = function(_, code, _)
	  M.jobs[job_id].status = "Finished"
	  M.jobs[job_id].exit_code = code
    end,
  })

  M.jobs[job_id] = {
    cmd = cmd,
    id = job_id,
	local_id = M.job_id,
    status = "Running",
    output = "",
  }
  M.job_id = M.job_id + 1
end

local function list_jobs()
  pickers.new({}, {
    prompt_title = "Background Jobs",

    finder = finders.new_table {
      results = vim.tbl_values(M.jobs),
      entry_maker = function(entry)
		local tail = " running"
		if entry.status == "Finished" then
		  if entry.exit_code == 0 then
		  	tail = " success"
		  else
			tail = " error"
		  end
		end
		local display = "[" .. entry.local_id .. tail .. "] " .. table.concat(entry.cmd, " ")
        return {
          value = entry,
          display = display,
          ordinal = display,
        }
      end,
    },

	previewer = previewers.new_buffer_previewer {
      title = "My preview",
      define_preview = function (self, entry, status)
        local selection = action_state.get_selected_entry()
        if selection then
		  vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(selection.value.output, "\n"))
        end
      end
    },

    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)

      local delete_job = function()
        local selection = action_state.get_selected_entry()
        if selection then
          vim.fn.jobstop(selection.value.id)
          M.jobs[selection.value.id].status = "Stopped"
          actions.close(prompt_bufnr)
          print("Stopped job " .. selection.value.id)
        end
      end

      map("i", "<C-d>", delete_job)
      map("n", "<C-d>", delete_job)

      local show_output = function()
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("new")
          vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(selection.value.output, "\n"))
          actions.close(prompt_bufnr)
        end
      end

      map("i", "<CR>", show_output)
      map("n", "<CR>", show_output)

      return true
    end,
  }):find()
end


return {
	setup = setup,
	start_job = start_job,
	list_jobs = list_jobs,
}
