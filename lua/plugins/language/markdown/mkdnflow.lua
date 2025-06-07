return {
  {
    -- Markdown 笔记增强插件
    "jakewvincent/mkdnflow.nvim",
    ft = { "markdown" },
    config = function()
      require("mkdnflow").setup({
        -- 启用智能列表续行：在列表中按回车自动创建新项
        mappings = {
          MkdnEnter = { { 'i', 'n', 'v' }, '<CR>' }, -- 插入/普通/可视模式下的回车映射
        },
      })
    end,
  },
}
