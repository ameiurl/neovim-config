vim.keymap.set({ "n", "v", "x" },  "<leader>ck", function()
  require("codecompanion").toggle()
end)
vim.keymap.set({ "n", "v", "x" },  "<leader>cp", ":CodeCompanionActions<CR>")

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      local copilot = require("copilot")
      if not copilot then
        return
      end
      copilot.setup({
        suggestion = { enabled = false, auto_trigger = true },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      local copilot_cmp = require("copilot_cmp")
      if copilot_cmp then
        copilot_cmp.setup()
      end
    end,
  },
   {
    "olimorris/codecompanion.nvim",
    config = function()
    require("codecompanion").setup({
        adapters = {
            opts = {
              -- show_defaults 会导致copilot不能正常工作
              show_defaults = true,
              -- log_level = "DEBUG",
            },

            deepseek = function()
              return require("codecompanion.adapters").extend("deepseek", {
                name = "deepseek",
                env = {
                  api_key = function()
                    return os.getenv("DEEPSEEK_API_KEY")
                  end,
                },
                schema = {
                  model = {
                    default = "deepseek-coder",
                  },
                },
              })
            end,

            siliconflow_r1 = function()
              return require("codecompanion.adapters").extend("deepseek", {
                name = "siliconflow_r1",
                url = "https://api.siliconflow.cn/v1/chat/completions",
                env = {
                  api_key = function()
                    return os.getenv("DEEPSEEK_API_KEY_S")
                  end,
                },
                schema = {
                  model = {
                    default = "deepseek-ai/DeepSeek-R1",
                    choices = {
                      ["deepseek-ai/DeepSeek-R1"] = { opts = { can_reason = true } },
                      "deepseek-ai/DeepSeek-V3",
                    },
                  },
                },
              })
            end,

            siliconflow_v3 = function()
              return require("codecompanion.adapters").extend("deepseek", {
                name = "siliconflow_v3",
                url = "https://api.siliconflow.cn/v1/chat/completions",
                env = {
                  api_key = function()
                    return os.getenv("DEEPSEEK_API_KEY_S")
                  end,
                },
                schema = {
                  model = {
                    default = "deepseek-ai/DeepSeek-V3",
                    choices = {
                      "deepseek-ai/DeepSeek-V3",
                      ["deepseek-ai/DeepSeek-R1"] = { opts = { can_reason = true } },
                    },
                  },
                },
              })
            end,

            aliyun_deepseek = function()
              return require("codecompanion.adapters").extend("deepseek", {
                name = "aliyun_deepseek",
                url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions",
                env = {
                  api_key = function()
                    return os.getenv("DEEPSEEK_API_ALIYUN")
                  end,
                },
                schema = {
                  model = {
                    default = "deepseek-r1",
                    choices = {
                      ["deepseek-r1"] = { opts = { can_reason = true } },
                    },
                  },
                },
              })
            end,
            -- 阿里千问
            -- https://help.aliyun.com/zh/model-studio/getting-started/models?spm=a2c4g.11186623.0.0.ce3c4823l7PTRL#9f8890ce29g5u
            aliyun_qwen = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                name = "aliyun_qwen",
                env = {
                  url = "https://dashscope.aliyuncs.com",
                  api_key = function()
                    return os.getenv("DEEPSEEK_API_ALIYUN")
                  end,
                  chat_url = "/compatible-mode/v1/chat/completions",
                },
                schema = {
                  model = {
                    default = "qwen-coder-plus-latest",
                  },
                },
              })
            end,

            copilot_claude = function()
              return require("codecompanion.adapters").extend("copilot", {
                name = "copilot_claude",
                schema = {
                  model = {
                    default = "claude-3.5-sonnet",
                  },
                },
              })
            end,
          },

          strategies = {
            chat = { adapter = "copilot_claude" },
            inline = { adapter = "copilot_claude" },
          },

          opts = {
            language = "Chinese",
          },
          -------------------------------------------
          prompt_library = {
            ["DeepSeek Explain"] = {
                      strategy = "chat",
                      description = "中文解释代码",
                      opts = {
                        is_slash_cmd = false,
                        modes = { "v" },
                        short_name = "explain in chinese",
                        auto_submit = true,
                        user_prompt = false,
                        stop_context_insertion = true,
                        adapter = {
                          name = "aliyun_deepseek",
                          model = "deepseek-r1",
                        },
                      },
                      prompts = {
                        {
                          role = "system",
                          content = [[当被要求解释代码时，请遵循以下步骤：

                      1. 识别编程语言。
                      2. 描述代码的目的，并引用该编程语言的核心概念。
                      3. 解释每个函数或重要的代码块，包括参数和返回值。
                      4. 突出说明使用的任何特定函数或方法及其作用。
                      5. 如果适用，提供该代码如何融入更大应用程序的上下文。]],
                          opts = {
                            visible = false,
                          },
                        },
                        {
                          role = "user",
                          content = function(context)
                            local input = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                            return string.format(
                              [[请解释 buffer %d 中的这段代码:

                      ```%s
                      %s
                      ```
                      ]],
                              context.bufnr,
                              context.filetype,
                              input
                            )
                          end,
                          opts = {
                            contains_code = true,
                          },
                        },
                      },
                },
            ["Nextjs Agant"] = {

                      strategy = "workflow",
                      description = "Nextjs Agant",
                      opts = {
                        is_default = false,
                        short_name = "nextjs",
                        ignore_system_prompt = true,
                        adapter = "copilot_claude",
                      },
                      references = {
                        {
                          type = "file",
                          path = {
                            "package.json",
                          },
                        },
                      },
                      prompts = {
                        {
                          -- We can group prompts together to make a workflow
                          -- This is the first prompt in the workflow
                          -- Everything in this group is added to the chat buffer in one batch
                          {
                            role = "system",
                            content = function(_)
                              return "As a senior Nextjs 15 developer. Your task is to design and generate high-quality Next.js components based on user prompts, ensuring it is functional, clean, and follows best practices."
                                .. "When generating code, always use the latest version of shadcn ui components or library from package.json file, unless otherwise specified. if you use any shadcn component, don't forget to tell me how to install it in both npx and pnpm way."
                                .. "The implemented component needs to be placed in a <new folder> within the components folder. Try to implement the component in a single file and provide the folder and file name information. If the implementation of the component is too complex and requires splitting into different files, all files should be placed in that folder, and the file names should be provided."
                                .. "If the component is a client component don't forget to add 'use client'"
                                .. "Style only with tailwindcss. No css inline style allowed, Responsive design, mobile-first principle."
                                .. "You can only use lucide-react and react-icons package if you see that the user's request requires icons."
                                .. "You can only use framer-motion (motion/react) package from motion.dev if you see that the user's request requires animnation."
                            end,
                            -- 详细规则
                            -- state management ?
                            -- react-hook-form + zod ?
                            -- 设计规范?
                            -- 样式 间距，颜色，字体，字号，行高，阴影，圆角，边框，背景色，hover，active，focus，disabled
                            opts = {
                              visible = false,
                            },
                          },
                          {
                            role = "user",
                            content = "我想要",
                            opts = {
                              auto_submit = false,
                            },
                          },
                        },
                        -- This is the second group of prompts
                        {
                          {
                            role = "user",
                            opts = {
                              auto_submit = false,
                            },
                            content = function()
                              -- Leverage auto_tool_mode which disables the requirement of approvals and automatically saves any edited buffer
                              vim.g.codecompanion_auto_tool_mode = true

                              -- Some clear instructions for the LLM to follow
                              return [[### Instructions Steps to Follow

                    @files You are instructed to strictly follow the guidelines below to execute the task:

                    1. @files Create the corresponding component folder and files in the components folder using appropriate naming.
                    2. @files Create a test page in the `app/playground/ + component folder name` directory and import the component. And adjust the layout and styling to make it visually appealing and user-friendly. The page will adopt a clean and simple design.
                    3. Print the test URL for the user to view the result. The URL is typically `http://localhost:3000/playground/ + component name`.
                    4. I'm using mac, so @cmd_runner just call `open + URL` to open the browser.

                    Don't help me install dependencies, just remind me that I need them, and I'll install them by myself. 
                    ]]
                            end,
                          },
                        },
                      },
                },
          },

    })
    end,
    },
    {
    "j-hui/fidget.nvim",
    config = function()
        local fidget = require("fidget")
        fidget.setup()
        local handler
        if fidget then
          vim.api.nvim_create_autocmd({ "User" }, {
            pattern = "CodeCompanionRequest*",
            group = vim.api.nvim_create_augroup("CodeCompanionHooks", {}),
            callback = function(request)
              if request.match == "CodeCompanionRequestStarted" then
                if handler then
                  handler.message = "Abort."
                  handler:cancel()
                  handler = nil
                end
                handler = fidget.progress.handle.create({
                  title = "",
                  message = "Thinking...",
                  lsp_client = { name = "CodeCompanion" },
                })
              elseif request.match == "CodeCompanionRequestFinished" then
                if handler then
                  handler.message = "Done."
                  handler:finish()
                  handler = nil
                end
              end
            end,
          })
        end
    end,
    }
  }
