local helpers = require('test.functional.helpers')(after_each)
local Screen = require('test.functional.ui.screen')
local nvim =  helpers.nvim
local clear, command, feed = helpers.clear, helpers.command, helpers.feed
local eq = helpers.eq

describe('git_fastfix', function()
 local screen
 local screen_width = 80

 local plugin_dir = os.getenv("TEST_FILE"):match("(.*)/spec")
 local spec_dir = plugin_dir .. "/spec"
 local demo_path = spec_dir .. '/demo'

 before_each(function()
   clear()
   screen = Screen.new(screen_width, 10)
   screen:attach()

   local demo_git_path = spec_dir .. '/demo.git'
   command('!cp -R ' .. demo_git_path .. ' ' .. demo_path .. '/.git')
   feed('<cr>')
   command('!cd ' .. demo_path .. ' && git reset --hard HEAD')
   feed('<cr>')
   command('luafile ' .. plugin_dir .. '/lua/git_fastfix/init.lua')
 end)

 after_each(function()
   command('!rm -rf ' .. demo_path .. '/.git')
   feed('<cr>')
   screen:detach()
 end)

 local function go_to_demo_project()
   command('cd ' .. demo_path)
 end

 local function update_file_from_second_commit()
   command('e second_commit.txt')
   feed('iupdated <esc>:w<cr>')
 end

 local function open_fixup_window()
   command('lua OpenGitFastFixWindow()')
 end

 local function expect_git_patch_window()
   screen:expect([[
diff --git a/second_commit.txt b/second_commit.txt                              |
index e019be0..9dd24c0 100644                                                   |
--- a/second_commit.txt                                                         |
+++ b/second_commit.txt                                                         |
@@ -1 +1 @@                                                                     |
-second                                                                         |
+updated second                                                                 |
Stage this hunk [y,n,q,a,d,e,?]?                                                |
                                                                                |
-- TERMINAL --                                                                  |
   ]])
 end

 local function expect_git_log_window()
   screen:expect([[
updated^c9a08ee third commit                                                     |
~      cd7e3cf second commit                                                    |
~      f3f7b0a first commit                                                     |
~                                                                               |
~                                                                               |
~                                                                               |
~                                                                               |
~                                                                               |
~                                                                               |
                                                                                |
   ]])
 end

 local function choose_second_commit()
   feed('j<cr>')
 end

 local function expect_notification_about_applied_patch()
  screen:expect([[
updated^ second                                                                  |
~                                                                               |
~                                                                               |
~                                                                               |
~                                                                               |
~                                                                               |
~                                                                               |
~                                                                               |
~                                                                               |
Patch applied to cd7e3cf second commit                                          |
  ]])
 end

 it('applies git "fixup" for the choosen commit', function()
    go_to_demo_project()
    update_file_from_second_commit()

    open_fixup_window()

    expect_git_patch_window()
    feed('y<cr>') -- confirm git hunk

    expect_git_log_window()
    choose_second_commit()
    expect_notification_about_applied_patch()
 end)
end)
