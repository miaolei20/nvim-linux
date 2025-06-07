-- Core Settings
vim.g.loaded_man = 1
vim.g.loaded_man_plugin = 1

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmode = false
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append("c")
vim.opt.updatetime = 300
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.confirm = true
vim.opt.clipboard = "unnamedplus"

if vim.fn.has("unix") == 1 then
  -- 检测 Wayland 环境
  if os.getenv("WAYLAND_DISPLAY") then
    vim.g.clipboard = {
      name = "wl-clipboard (Wayland)",
      copy = {
        ["+"] = { "wl-copy", "--type", "text/plain" },
        ["*"] = { "wl-copy", "--type", "text/plain", "--primary" },
      },
      paste = {
        ["+"] = { "wl-paste", "--no-newline" },
        ["*"] = { "wl-paste", "--no-newline", "--primary" },
      },
      cache_enabled = 1,
    }
  else
    -- 回退到 X11 配置
    if vim.fn.executable("xclip") == 1 then
      vim.g.clipboard = {
        name = "xclip (X11 clipboard)",
        copy = {
          ["+"] = { "xclip", "-selection", "clipboard" },
          ["*"] = { "xclip", "-selection", "primary" },
        },
        paste = {
          ["+"] = { "xclip", "-selection", "clipboard", "-o" },
          ["*"] = { "xclip", "-selection", "primary", "-o" },
        },
        cache_enabled = 1,
      }
    end
  end
end

-- Debug logging (optional)
local function debug_log(msg)
  if vim.g.debug_settings then
    vim.notify("[Settings] " .. msg, vim.log.levels.DEBUG)
  end
end

-- Autocommands
local function setup_autocommands()
  debug_log("Setting up autocommands")

  -- Auto-save
  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost" }, {
    pattern = "*",
    callback = function()
      if vim.bo.modified and vim.bo.modifiable and not vim.bo.buftype:match("^(nofile|terminal|prompt)$") then
        pcall(vim.cmd.write)
      end
    end,
    desc = "Auto-save on buffer changes",
  })

  -- Yank highlight
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    callback = function()
      vim.highlight.on_yank { timeout = 300 }
    end,
    desc = "Highlight yanked text",
  })
end

-- Compile and Run
local function compile_and_run()
  if vim.bo.modified then
    pcall(vim.cmd.write)
  end

  local file = {
    path = vim.fn.expand("%:p"),
    name = vim.fn.expand("%:t"),
    base = vim.fn.expand("%:t:r"),
    ext = vim.fn.expand("%:e"):lower(),
    dir = vim.fn.expand("%:p:h"),
  }

  local runners = {
    c = { cmd = "gcc", args = { file.name, "-o", file.base }, run = "./" .. file.base },
    cpp = { cmd = "g++", args = { file.name, "-o", file.base }, run = "./" .. file.base },
    py = { cmd = "python3", args = { file.name } },
    java = { cmd = "javac", args = { file.name }, run = "java " .. file.base },
    go = { cmd = "go", args = { "run", file.name } },
  }

  local runner = runners[file.ext]
  if not runner then
    vim.notify("[Error] Unsupported file type: " .. file.ext, vim.log.levels.ERROR)
    return
  end

  local cmd_parts = { "cd", vim.fn.shellescape(file.dir), "&&", runner.cmd }
  vim.list_extend(cmd_parts, runner.args)
  if runner.run then
    vim.list_extend(cmd_parts, { "&&", runner.run })
  end
  local cmd = table.concat(cmd_parts, " ")

  local width = math.min(85, math.floor(vim.o.columns * 0.8))
  local height = math.min(15, math.floor(vim.o.lines * 0.4))
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
  })

  vim.fn.termopen(cmd, {
    on_exit = function(_, code)
      if code ~= 0 then
        vim.api.nvim_buf_set_lines(buf, -1, -1, true, { "[Error] Exit code: " .. code })
      end
      vim.api.nvim_buf_set_option(buf, "modifiable", false)
    end,
  })
  vim.cmd.startinsert()
end

-- Commands and Keymaps
local function setup_commands()
  vim.api.nvim_create_user_command("RunCode", compile_and_run, { desc = "Run current file" })
  vim.keymap.set("n", "<F5>", ":RunCode<CR>", { silent = true, desc = "Run Code" })
  vim.keymap.set("n", "<leader>y", '"+y', { noremap = true, silent = true, desc = "Copy to system clipboard" })
end

-- Initialization
local function init()
  setup_autocommands()
  setup_commands()
  debug_log("Initialization complete")
end

init()
