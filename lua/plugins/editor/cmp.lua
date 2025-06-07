return {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
        {
            "windwp/nvim-autopairs",
            event = "InsertEnter",
            opts = {
                disable_filetype = { "TelescopePrompt", "vim" },
                map_cr = true,
                map_bs = true,
                check_ts = true,
            },
        },
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        -- Load snippets
        require("luasnip.loaders.from_vscode").lazy_load()

        -- Debug logging
        local function debug_log(msg)
            if vim.g.debug_cmp then
                vim.notify("[nvim-cmp] " .. msg, vim.log.levels.DEBUG)
            end
        end

        -- Formatting configuration
        local function setup_formatting()
            local icons = {
                Text = "󰉿",
                Method = "󰆧",
                Function = "󰊕",
                Constructor = "󰒓",
                Field = "󰜢",
                Variable = "󰀫",
                Class = "󰠱",
                Interface = "",
                Module = "󰏗",
                Property = "󰜢",
                Unit = "󰑭",
                Value = "󰎠",
                Enum = "󰕘",
                Keyword = "󰌋",
                Snippet = "",
                Color = "󰏘",
                File = "󰈙",
                Reference = "󰈇",
                Folder = "󰉋",
                EnumMember = "󰕚",
                Constant = "󰏿",
                Struct = "󰙅",
                Event = "",
                Operator = "󰆕",
                TypeParameter = "󰊄",
            }
            return {
                fields = { "kind", "abbr" },
                format = function(_, item)
                    item.kind = string.format("%s  %s", icons[item.kind] or "󰉿", item.kind)
                    return item
                end,
            }
        end

        -- Window configuration
        local function setup_windows()
            return {
                completion = cmp.config.window.bordered({
                    border = "none",
                    winhighlight = "Normal:NormalFloat,CursorLine:Visual",
                    scrollbar = false,
                }),
                documentation = cmp.config.window.bordered({
                    border = "none",
                    winhighlight = "Normal:NormalFloat",
                    max_width = 80,
                    max_height = 20,
                    scrollbar = false,
                }),
            }
        end

        -- Mapping configuration
        local function setup_mappings()
            return cmp.mapping.preset.insert({
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping({
                    i = function(fallback)
                        if cmp.visible() and cmp.get_active_entry() then
                            cmp.confirm({ select = false })
                        else
                            fallback()
                        end
                    end,
                    s = cmp.mapping.confirm({ select = true }),
                }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            })
        end

        -- Core completion setup
        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = setup_mappings(),
            sources = cmp.config.sources({
                { name = "nvim_lsp", priority = 1000 },
                { name = "luasnip", priority = 800 },
                { name = "buffer", priority = 500 },
                { name = "path", priority = 400 },
            }),
            formatting = setup_formatting(),
            window = setup_windows(),
            experimental = { ghost_text = false },
            performance = {
                debounce = 40,
                throttle = 20,
                fetching_timeout = 120,
            },
        })

        -- Command-line completion setup
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" },
            },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
                { name = "cmdline" },
            }),
        })

        -- Integrate nvim-autopairs with cmp
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

        debug_log("Completion setup complete")
    end,
}