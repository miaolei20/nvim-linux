return {
  {
    -- Markdown 渲染插件，预览效果美化
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" }, -- 仅在 Markdown 文件加载
    config = function()
      -- 启用插件，使用默认配置
      require("render-markdown").setup({})
    end,
  },
}
