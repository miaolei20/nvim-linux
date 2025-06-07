return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost" }, -- 保存时加载
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local lint = require("lint")
      local mason_registry = require("mason-registry")

      -- 使用 Neovim 内置诊断显示
      vim.g.lint_use_diagnostics = true

      -- 辅助函数：获取 Mason 安装路径的可执行文件路径
      local function get_mason_bin(pkg_name, exe_name)
        exe_name = exe_name or pkg_name
        if not mason_registry.is_installed(pkg_name) then
          return exe_name -- fallback：直接用命令名，依赖全局 PATH
        end
        local pkg = mason_registry.get_package(pkg_name)
        return pkg:get_install_path() .. "/bin/" .. exe_name
      end

      -- 配置各语言 linters
      lint.linters_by_ft = {
        c = { "cpplint" },
        cpp = { "cpplint" },
        python = { "flake8" },
        markdown = { "markdownlint" },
      }

      -- cpplint 配置
      lint.linters.cpplint = {
        cmd = get_mason_bin("cpplint"),
        args = { "--filter=-legal/copyright,-build/include_order", "--linelength=120" },
        stdin = false,
      }

      -- flake8 配置
      lint.linters.flake8 = {
        cmd = get_mason_bin("flake8"),
        args = { "--max-line-length=88", "--ignore=E203,W503" },
        stdin = false,
      }

      -- markdownlint 配置，使用 markdownlint-cli2（Mason 中名为 markdownlint-cli2）
      lint.linters.markdownlint = {
        cmd = get_mason_bin("markdownlint-cli2"),
        args = { "--config", vim.fn.expand("~/.config/.markdownlint-cli2.yaml") }, -- 配置文件路径可按需修改
        stdin = false,
      }

      -- 自动保存后触发 lint 检查
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        pattern = { "*.c", "*.cpp", "*.h", "*.py", "*.md", "*.markdown" },
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
