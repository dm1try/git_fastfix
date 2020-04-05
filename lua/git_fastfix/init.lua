function FixupToTheCommit()
  local commit_hash = vim.split(vim.api.nvim_get_current_line(), ' ')[1]
  vim.api.nvim_call_function('system', { "git commit --fixup " .. commit_hash })
  vim.api.nvim_call_function('system', { "GIT_EDITOR=true git rebase -i --autosquash --autostash " .. commit_hash .. "^" })
  vim.api.nvim_command("echo 'Patch applied to " .. vim.api.nvim_get_current_line() .. "'")
  vim.api.nvim_command("close")
end

function ShowGitLog()
  local buf = vim.api.nvim_create_buf(false, true)
  local git_log_output = vim.api.nvim_call_function('system', {'git log -n 10 --oneline'})
  local git_logs = vim.split(git_log_output, "\n")

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, git_logs)
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>' ,':lua FixupToTheCommit()<cr>',{})
end

function OpenGitFastFixWindow()
  local source_code_filename = vim.api.nvim_buf_get_name(0)

  local buf = vim.api.nvim_create_buf(false, true)
  local opts = {
    relative='cursor',
    width=80, height=20,
    col=0, row=1, anchor='NW', style='minimal'
  }
  local win = vim.api.nvim_open_win(buf, 0, opts)
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_call_function('termopen', {'git add --patch ' .. source_code_filename})
  vim.api.nvim_command('startinsert')
  vim.api.nvim_command(":autocmd TermClose <buffer> :lua ShowGitLog()")
end
