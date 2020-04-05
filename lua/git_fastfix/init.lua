local nvim_win_set_config = vim.api.nvim_win_set_config
local nvim_open_win = vim.api.nvim_open_win
local nvim_win_set_buf = vim.api.nvim_win_set_buf
local nvim_create_buf = vim.api.nvim_create_buf
local nvim_call_function = vim.api.nvim_call_function
local nvim_set_current_win = vim.api.nvim_set_current_win
local nvim_command = vim.api.nvim_command
local nvim_buf_get_name = vim.api.nvim_buf_get_name
local nvim_buf_set_keymap = vim.api.nvim_buf_set_keymap
local nvim_buf_set_lines = vim.api.nvim_buf_set_lines
local nvim_get_current_line = vim.api.nvim_get_current_line
local split = vim.split

local function nvim_shell_call(command)
  return nvim_call_function('system', { command })
end

local function nvim_term_open(command)
  return nvim_call_function('termopen', { command })
end

function FixupToTheCommit()
  local commit_hash = split(nvim_get_current_line(), ' ')[1]
  nvim_shell_call('git commit --fixup ' .. commit_hash)
  nvim_shell_call('GIT_EDITOR=true git rebase -i --autosquash --autostash ' .. commit_hash .. '^')
  nvim_command("echo 'Patch applied to " .. nvim_get_current_line() .. "'")
  nvim_command("close")
end

function ShowGitLog()
  local buf = nvim_create_buf(false, true)
  local git_log_output = nvim_shell_call('git log -n 10 --oneline')
  local git_logs = split(git_log_output, "\n")

  nvim_buf_set_lines(buf, 0, -1, true, git_logs)
  nvim_win_set_buf(0, buf)
  nvim_buf_set_keymap(buf, 'n', '<CR>' ,':lua FixupToTheCommit()<cr>',{})
end

function OpenGitFastFixWindow()
  local source_code_filename = nvim_buf_get_name(0)

  local buf = nvim_create_buf(false, true)
  local opts = {
    relative='cursor',
    width=80, height=20,
    col=0, row=1, anchor='NW', style='minimal'
  }
  local win = nvim_open_win(buf, 0, opts)
  nvim_set_current_win(win)
  nvim_term_open('git add --patch ' .. source_code_filename)
  nvim_command('startinsert')
  nvim_command(":autocmd TermClose <buffer> :lua ShowGitLog()")
end
