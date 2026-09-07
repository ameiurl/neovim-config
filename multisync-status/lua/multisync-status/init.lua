--[[
multisync-status.nvim —— 本地迷你插件

在编辑器右下角显示一个小浮窗（默认无边框、无标题，只有日志内容），
实时 tail 读取多端同步日志（默认 /home/amei/multi_sync.log），
每次文件保存(BufWritePost)或日志文件有新写入时自动弹出刷新；
没有新消息后 hide_after_ms 毫秒（默认 3 秒）自动隐藏。

只监控范围：打开的文件位于同步项目目录内才显示。项目名自动读取
sync_multi.sh 里的 PROJECT_BASE_NAMES，目录 = root + '/' + 项目名
（默认 /server/www/mallphp 等）；脚本内容变化会自动重新解析。

用法（lazy.nvim spec 里配置）：
  require('multisync-status').setup({
    logfile      = '/home/amei/multi_sync.log',
    interval_ms  = 750,   -- 轮询间隔（fs_stat 很便宜，可调小）
    hide_after_ms = 3000, -- 没有新消息后多久自动隐藏；0 = 常驻显示
    max_lines    = 4,     -- 显示最近几行
    max_width    = 76,    -- 浮窗最大宽度
    margin       = 1,     -- 距屏幕右下角留白
    border       = 'none', -- 不要外框；想要框可改 'rounded'
    title        = nil,   -- 标题行（如 'multi_sync.log'），nil = 不显示
    script       = '/home/amei/rsync_win_linux/sync_multi.sh', -- 读取 PROJECT_BASE_NAMES 的脚本
    root         = '/server/www', -- 项目根目录
    projects     = nil,   -- 手动指定项目名列表则跳过解析（如 { 'mallphp' }）
    enabled      = true,  -- 启动即开启监听
    keymap       = nil,   -- 例如 '<leader>ms' 绑定开关
  })

命令：
  :MultiSyncToggle   显示/隐藏
  :MultiSyncRefresh  立即重新读取
--]]

local uv = vim.uv or vim.loop

local ns = vim.api.nvim_create_namespace('multisync-status')
local augroup = vim.api.nvim_create_augroup('MultiSyncStatus', { clear = true })

local M = {}

local defaults = {
  logfile = '/home/amei/multi_sync.log',
  interval_ms = 750,
  hide_after_ms = 3000,
  max_lines = 4,
  max_width = 76,
  margin = 1,
  zindex = 60,
  border = 'none',
  title = nil,
  script = '/home/amei/rsync_win_linux/sync_multi.sh',
  root = '/server/www',
  projects = nil,
  enabled = true,
  keymap = nil,
}

local opts = {}

local state = {
  timer = nil,
  hide_timer = nil,
  buf = nil,
  win = nil,
  on = true, -- 运行时开关（:MultiSyncToggle 切换）
  last_key = nil, -- 上次 stat 指纹 (size/mtime)，日志没变就不重绘
  missing = false, -- 日志文件当前是否存在
  rows = {}, -- 最近 max_lines 行原文
  drawn = nil, -- 已绘制文本签名（用于跳过无变化重绘）
  drawn_w = 0,
  defer_pending = false,
  warned = false,
  dirs = nil, -- 监控目录列表（/server/www/<项目名>）；nil = 不限制
  script_key = nil, -- 脚本 stat 指纹，变了就重新解析 PROJECT_BASE_NAMES
  warned_parse = false,
}

-- 每次最多只读文件尾部 16KB，足够覆盖 max_lines 的最新内容
local TAIL_BYTES = 16384

---@private 读取文件最后 n 行（非空行）
---@param path string
---@param n number
---@return string[]?
local function tail(path, n)
  local f = io.open(path, 'rb')
  if not f then
    return nil
  end
  local size = f:seek('end')
  local start = math.max(0, size - TAIL_BYTES)
  f:seek('set', start)
  local chunk = f:read('*a')
  f:close()

  -- 若截断在行中间，丢弃第一段不完整行
  if start > 0 then
    local nl = chunk:find('\n')
    if nl then
      chunk = chunk:sub(nl + 1)
    end
  end

  local all = {}
  for line in chunk:gmatch('[^\r\n]+') do
    all[#all + 1] = line
  end

  local out = {}
  local first = math.max(1, #all - n + 1)
  for i = first, #all do
    out[#out + 1] = all[i]
  end
  return out
end

---@private 按显示宽度截断（CJK 算 2 列），超长加省略号
---@param s string
---@param w number
---@return string
local function trunc(s, w)
  if vim.fn.strwidth(s) <= w then
    return s
  end
  local n = w
  while n > 1 do
    local part = vim.fn.strcharpart(s, 0, n)
    if vim.fn.strwidth(part) <= w - 1 then
      return part .. '…'
    end
    n = n - 1
  end
  return '…'
end

-- ============================================================================
-- 监控范围：解析 sync_multi.sh 的 PROJECT_BASE_NAMES，只监控这些项目目录
-- ============================================================================

---@private 从 bash 脚本解析 PROJECT_BASE_NAMES=( ... ) 里的项目名
---@param path string
---@return string[]? nil = 解析失败
local function parse_projects_from_script(path)
  local f = io.open(path, 'rb')
  if not f then
    return nil
  end
  local content = f:read('*a')
  f:close()

  local projects = {}
  local in_block = false
  for line in content:gmatch('[^\r\n]+') do
    if not in_block then
      if line:find('^%s*PROJECT_BASE_NAMES%s*=%s*%(') then
        in_block = true
      end
    else
      if line:find('^%s*%)') then
        break
      end
      local name = line:match('^%s*"([^"]+)"') or line:match("^%s*'([^']+)'")
      if name and name ~= '' then
        projects[#projects + 1] = name
      end
    end
  end
  if #projects == 0 then
    return nil
  end
  return projects
end

---@private 更新监控目录列表；脚本变了自动重新解析（配置 projects 时用配置）
local function refresh_dirs()
  local projects = opts.projects
  if projects == nil or #projects == 0 then
    projects = nil
    local st = uv.fs_stat(opts.script)
    if st then
      local key = ('%d|%d'):format(st.size, st.mtime.sec)
      if key ~= state.script_key then
        state.script_key = key
        projects = parse_projects_from_script(opts.script)
      else
        return -- 脚本没变，无需重算
      end
    end
  end
  if projects and #projects > 0 then
    local dirs = {}
    for _, name in ipairs(projects) do
      if type(name) == 'string' and name ~= '' then
        local d = (opts.root .. '/' .. name):gsub('/+$', '')
        -- 统一解析成真实路径，与 current_path_real() 比较才可靠
        local real = uv.fs_realpath and uv.fs_realpath(d) or nil
        dirs[#dirs + 1] = real or d
      end
    end
    state.dirs = dirs
  elseif not state.warned_parse then
    state.warned_parse = true
    state.dirs = nil -- 解析失败且未手动配置：退回不限制（提示一次）
    vim.notify(
      '[multisync-status] 未从 ' .. opts.script
        .. ' 解析到 PROJECT_BASE_NAMES，暂时不限目录显示；可在 setup({ projects = {...} }) 手动指定',
      vim.log.levels.WARN
    )
  end
end

---@private 当前缓冲区真实路径（解析符号链接）
---@return string?
local function current_path_real()
  local p = vim.fn.expand('%:p')
  if not p or p == '' then
    return nil
  end
  if uv.fs_realpath then
    local real = uv.fs_realpath(p)
    if real then
      return real
    end
  end
  return vim.fn.resolve(p)
end

---@private 当前打开的文件是否在监控目录内
local function relevant()
  if not state.dirs then
    return true
  end
  local real = current_path_real()
  if not real then
    return false
  end
  for _, d in ipairs(state.dirs) do
    if real == d or real:sub(1, #d + 1) == d .. '/' then
      return true
    end
  end
  return false
end

-- 按日志内容给每行配色（fidget 式状态感）
---@param line string
---@return string hl group
local function line_hl(line)
  if line:find('❌', 1, true) or line:find('✗', 1, true) then
    return 'MultiSyncErr'
  end
  if line:find('⚠', 1, true) then
    return 'MultiSyncWarn'
  end
  if line:find('✅', 1, true) or line:find('✔', 1, true) then
    return 'MultiSyncOk'
  end
  if line:find('🔄', 1, true) or line:find('🔁', 1, true) then
    return 'MultiSyncBusy'
  end
  if line:match('^%s') then
    return 'MultiSyncDetail' -- 文件路径等缩进明细，弱化显示
  end
  return 'MultiSyncLine'
end

-- 浮窗几何：右下角、压在状态栏之上
---@return number w 窗口宽度(含边框), number bottom 底部行(SE anchor), number right 右侧列(SE anchor)
local function geom()
  local cols, lines = vim.o.columns, vim.o.lines
  local reserved = 0
  if vim.o.cmdheight >= 1 then
    reserved = reserved + 1
  end
  if vim.o.laststatus >= 2 then
    reserved = reserved + 1
  end
  local w = math.min(opts.max_width, cols - 2 * opts.margin - 2)
  w = math.max(16, w)
  local bottom = lines - 1 - reserved - opts.margin
  local right = cols - 1 - opts.margin
  return w, bottom, right
end

local function close_win()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state.win = nil
  state.drawn = nil
end

local function ensure_buf()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    return state.buf
  end
  local b = vim.api.nvim_create_buf(false, true)
  vim.bo[b].buftype = 'nofile'
  vim.bo[b].bufhidden = 'hide'
  vim.bo[b].swapfile = false
  state.buf = b
  return b
end

---@return boolean 是否能创建浮窗（有 UI 才显示）
local function ensure_win()
  if #vim.api.nvim_list_uis() == 0 then
    return false
  end
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    return true
  end
  local w = geom()
  local b = ensure_buf()
  local ok, win = pcall(vim.api.nvim_open_win, b, false, {
    relative = 'editor',
    style = 'minimal',
    anchor = 'SE',
    row = 0,
    col = 0,
    width = w,
    height = 1,
    border = opts.border,
    zindex = opts.zindex,
    focusable = false,
  })
  if not ok then
    return false
  end
  state.win = win
  for opt, val in pairs({
    wrap = false,
    number = false,
    relativenumber = false,
    signcolumn = 'no',
    foldcolumn = '0',
    spell = false,
    list = false,
    cursorline = false,
    winblend = 0,
    conceallevel = 3,
    concealcursor = 'nvic',
  }) do
    pcall(vim.api.nvim_win_set_option, win, opt, val)
  end
  return true
end

-- 组装要显示的 { text, hl } 行（只有日志内容；有标题时标题在最上）
local function display_rows(content_w)
  local rows = {}
  if opts.title then
    rows[#rows + 1] = { text = trunc(opts.title, content_w), hl = 'MultiSyncTitle' }
  end
  for _, line in ipairs(state.rows) do
    rows[#rows + 1] = { text = trunc(line, content_w), hl = line_hl(line) }
  end
  return rows
end

-- 边框要占几列（'none' 为 0）
local function border_cols()
  return (opts.border and opts.border ~= 'none') and 2 or 0
end

local function apply_win()
  local w, bottom, right = geom()
  local content_w = math.max(4, w - 2 - border_cols()) -- 左右各 1 列留白 + 边框
  local rows = display_rows(content_w)

  -- 没有内容（日志缺失/为空/无可显示行）就不弹窗
  if #rows == 0 then
    close_win()
    state.drawn = nil
    return
  end

  if not ensure_win() then
    return
  end

  local texts = {}
  for i, r in ipairs(rows) do
    texts[i] = r.text
  end
  local sig = table.concat(texts, '\n')

  local b = ensure_buf()
  local need_place = state.drawn ~= sig or state.drawn_w ~= w

  vim.api.nvim_buf_set_lines(b, 0, -1, false, texts)
  vim.api.nvim_buf_clear_namespace(b, ns, 0, -1)
  for i, r in ipairs(rows) do
    if r.hl then
      vim.api.nvim_buf_add_highlight(b, ns, r.hl, i - 1, 0, -1)
    end
  end

  if need_place then
    local ok = pcall(vim.api.nvim_win_set_config, state.win, {
      relative = 'editor',
      style = 'minimal',
      anchor = 'SE',
      row = bottom,
      col = right,
      width = w,
      height = #rows,
      border = opts.border,
      zindex = opts.zindex,
      focusable = false,
    })
    if not ok then
      state.win = nil
      return
    end
  end

  state.drawn = sig
  state.drawn_w = w
end

-- 有新内容后启动(或重置)自动隐藏倒计时：hide_after_ms 内没有新消息就收起
local function arm_hide()
  if not state.on or not opts.hide_after_ms or opts.hide_after_ms <= 0 then
    return
  end
  if not state.hide_timer then
    state.hide_timer = uv.new_timer()
  end
  state.hide_timer:stop()
  state.hide_timer:start(opts.hide_after_ms, 0, vim.schedule_wrap(close_win))
end

-- 检查日志是否有更新，有则重绘
local function check()
  if not state.on then
    return
  end
  refresh_dirs()
  -- 只监控同步项目目录内打开的文件：不在范围内就不显示
  if state.dirs and not relevant() then
    if state.win and vim.api.nvim_win_is_valid(state.win) then
      close_win()
    end
    return
  end
  local ok, st = pcall(uv.fs_stat, opts.logfile)
  if not ok or not st then
    if not state.missing then
      state.missing = true
      state.rows = {}
      state.last_key = nil
      state.drawn = nil
      apply_win()
    end
    return
  end

  local key = ('%d|%d|%d'):format(st.size, st.mtime.sec, st.mtime.nsec or 0)
  if key ~= state.last_key then
    state.last_key = key
    local lines = tail(opts.logfile, opts.max_lines)
    state.rows = lines or {}
    state.missing = false
    state.drawn = nil
    apply_win()
    -- 有新消息：弹出后重新开始“无新消息自动隐藏”倒计时
    arm_hide()
  end
end

-- 进入缓冲/窗口时：在监控目录内则显示最近内容（有新消息直接显示新的），
-- 目录外则收起 —— “打开项目文件才显示”
local function on_enter_buffer()
  vim.schedule(function()
    if not state.on then
      return
    end
    refresh_dirs()
    if state.dirs and not relevant() then
      close_win()
      return
    end
    check() -- 有变化（含离开期间的更新）则渲染
    if not (state.win and vim.api.nvim_win_is_valid(state.win)) then
      apply_win() -- 无变化也把最近内容显示出来
    end
    arm_hide()
  end)
end

local function start_timer()
  if state.timer then
    pcall(state.timer.stop, state.timer)
    state.timer = nil
  end
  local t = uv.new_timer()
  t:start(opts.interval_ms, opts.interval_ms, vim.schedule_wrap(check))
  state.timer = t
end

local function stop_timer()
  if state.timer then
    pcall(state.timer.stop, state.timer)
    state.timer = nil
  end
  if state.hide_timer then
    pcall(state.hide_timer.stop, state.hide_timer)
  end
end

local function schedule_check(delay_ms)
  if state.defer_pending then
    return
  end
  state.defer_pending = true
  vim.defer_fn(function()
    state.defer_pending = false
    check()
  end, delay_ms or 250)
end

function M.toggle()
  state.on = not state.on
  if state.on then
    start_timer()
    vim.schedule(function()
      refresh_dirs()
      state.drawn = nil
      check() -- 有新变化则立即弹出
      if state.dirs and not relevant() then
        -- 当前文件不在同步项目目录内：不显示
        close_win()
        vim.notify('[multisync-status] 当前文件不在同步项目目录内，不显示', vim.log.levels.INFO)
        return
      end
      -- 没有新变化也把最近内容显示出来看一眼（随后同样自动隐藏）
      if not (state.win and vim.api.nvim_win_is_valid(state.win)) then
        apply_win()
      end
      arm_hide()
    end)
    vim.notify('[multisync-status] 监听中（打开同步项目文件时显示）', vim.log.levels.INFO)
  else
    stop_timer()
    close_win()
    vim.notify('[multisync-status] 已停止（:MultiSyncToggle 恢复）', vim.log.levels.INFO)
  end
end

function M.refresh()
  state.last_key = nil
  check()
end

---@param user? table 见文件头注释
function M.setup(user)
  user = user or {}
  opts = vim.tbl_deep_extend('force', defaults, user)

  -- 配色（跟随 colorscheme 的语义色，非写死）
  for group, def in pairs({
    MultiSyncTitle = { link = 'Title' },
    MultiSyncErr = { link = 'DiagnosticError' },
    MultiSyncWarn = { link = 'DiagnosticWarn' },
    MultiSyncOk = { link = 'DiagnosticOk' },
    MultiSyncBusy = { link = 'DiagnosticInfo' },
    MultiSyncDetail = { link = 'Comment' },
    MultiSyncLine = { link = 'Normal' },
    MultiSyncIdle = { link = 'Comment' },
  }) do
    vim.api.nvim_set_hl(0, group, def)
  end

  -- UI 就绪后立即读一次；切换缓冲/窗口时按目录范围显示或收起
  vim.api.nvim_create_autocmd('UIEnter', {
    group = augroup,
    callback = on_enter_buffer,
  })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'TabEnter' }, {
    group = augroup,
    callback = on_enter_buffer,
  })
  vim.api.nvim_create_autocmd('VimResized', {
    group = augroup,
    callback = function()
      vim.schedule(function()
        -- 只重新排版当前显示的浮窗，不把已自动隐藏的又拉出来
        if state.win and vim.api.nvim_win_is_valid(state.win) then
          state.drawn = nil
          apply_win()
        end
      end)
    end,
  })
  -- 修改(保存)文件时立刻刷新一次，其余时间靠轮询兜底
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = augroup,
    pattern = '*',
    callback = function()
      if state.on then
        schedule_check(250)
      end
    end,
  })

  pcall(vim.api.nvim_create_user_command, 'MultiSyncToggle', M.toggle, { force = true, desc = 'multisync-status: show/hide' })
  pcall(vim.api.nvim_create_user_command, 'MultiSyncRefresh', M.refresh, { force = true, desc = 'multisync-status: force re-read log' })

  if opts.keymap then
    vim.keymap.set('n', opts.keymap, '<Cmd>MultiSyncToggle<CR>', { desc = 'multisync-status toggle' })
  end

  stop_timer()
  state.on = opts.enabled
  if opts.enabled then
    start_timer()
    on_enter_buffer()
  end
end

M._debug = function()
  local win_ok = state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
  return {
    on = state.on,
    win_valid = win_ok,
    missing = state.missing,
    last_key = state.last_key,
    rows = state.rows,
    dirs = state.dirs,
    relevant = relevant(),
    cur_file = vim.fn.expand('%:p'),
  }
end

return M
