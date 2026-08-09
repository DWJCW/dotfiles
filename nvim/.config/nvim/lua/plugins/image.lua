return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      image = {
        enabled = true,
        doc = {
          -- Do not render LaTeX/Markdown source formulas and image references
          -- inline. Opening a standalone PDF/image buffer remains supported.
          enabled = false,
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
        },
        convert = {
          magick = {
            default = { "{src}[0]", "-background", "white", "-alpha", "remove", "-alpha", "off", "-scale", "1920x1080>" },
            vector = { "-density", 192, "{src}[{page}]", "-background", "white", "-alpha", "remove", "-alpha", "off" },
            math = { "-density", 192, "{src}[{page}]", "-background", "white", "-alpha", "remove", "-alpha", "off", "-trim" },
            pdf = { "-density", 192, "{src}[{page}]", "-background", "white", "-alpha", "remove", "-alpha", "off", "-trim" },
          },
        },
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      local state_by_buf = {}
      local page_count_cache = {}

      local function is_pdf(path)
        return path:lower():match("%.pdf$") ~= nil
      end

      local function page_count(path)
        if page_count_cache[path] ~= nil then
          return page_count_cache[path]
        end

        local out = vim.fn.systemlist({ "magick", "identify", "-format", "%n", path })
        local count = vim.v.shell_error == 0 and tonumber(out[1]) or nil
        page_count_cache[path] = count
        return count
      end

      local function state(buf)
        local path = vim.api.nvim_buf_get_name(buf)
        state_by_buf[buf] = state_by_buf[buf]
          or {
            file = path,
            page = 1,
            zoom = 1.0,
          }
        return state_by_buf[buf]
      end

      local function render(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        local s = state(buf)
        local win = vim.fn.bufwinid(buf)
        local win_width = win ~= -1 and vim.api.nvim_win_get_width(win) or vim.o.columns
        local win_height = win ~= -1 and vim.api.nvim_win_get_height(win) or vim.o.lines
        local src = s.file

        if is_pdf(s.file) then
          src = ("%s#page=%d"):format(s.file, s.page)
        end

        require("snacks.image.placement").clean(buf)
        require("snacks.image.placement").new(buf, src, {
          pos = { 1, 0 },
          inline = true,
          conceal = true,
          auto_resize = true,
          width = math.max(1, math.floor(win_width * s.zoom)),
          height = math.max(1, math.floor((win_height - 1) * s.zoom)),
        })

        local pages = is_pdf(s.file) and page_count(s.file) or nil
        local page_label = pages and ("%d/%d"):format(s.page, pages) or tostring(s.page)
        vim.notify(
          is_pdf(s.file) and ("PDF page %s, zoom %.0f%%"):format(page_label, s.zoom * 100)
            or ("Image zoom %.0f%%"):format(s.zoom * 100),
          vim.log.levels.INFO,
          { title = "snacks.image" }
        )
      end

      local function change_page(delta)
        local buf = vim.api.nvim_get_current_buf()
        local s = state(buf)

        if not is_pdf(s.file) then
          vim.notify("Current image is not a PDF", vim.log.levels.WARN, { title = "snacks.image" })
          return
        end

        local pages = page_count(s.file)
        local next_page = s.page + delta
        if pages then
          next_page = math.max(1, math.min(pages, next_page))
        else
          next_page = math.max(1, next_page)
        end

        if next_page == s.page then
          if delta < 0 then
            vim.notify("Already at the first page", vim.log.levels.INFO, { title = "snacks.image" })
          elseif pages and delta > 0 then
            vim.notify("Already at the last page", vim.log.levels.INFO, { title = "snacks.image" })
          end
          return
        end

        s.page = next_page
        render(buf)
      end

      local function change_zoom(delta)
        local buf = vim.api.nvim_get_current_buf()
        local s = state(buf)
        s.zoom = math.max(0.25, math.min(3.0, s.zoom + delta))
        render(buf)
      end

      local function setup_keys(buf)
        if vim.b[buf].snacks_image_keys then
          return
        end

        vim.b[buf].snacks_image_keys = true
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = desc })
        end

        map("<localleader>pp", function()
          change_page(-1)
        end, "Previous PDF page")
        map("<localleader>pn", function()
          change_page(1)
        end, "Next PDF page")
        map("+", function()
          change_zoom(0.25)
        end, "Zoom image in")
        map("=", function()
          change_zoom(0.25)
        end, "Zoom image in")
        map("-", function()
          change_zoom(-0.25)
        end, "Zoom image out")
        map("0", function()
          local s = state(buf)
          s.zoom = 1.0
          render(buf)
          end, "Reset image zoom")
      end

      local group = vim.api.nvim_create_augroup("user.snacks_image_controls", { clear = true })
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
        group = group,
        pattern = { "*.pdf" },
        callback = function(event)
          setup_keys(event.buf)
        end,
      })
      vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
        group = group,
        callback = function(event)
          state_by_buf[event.buf] = nil
        end,
      })
    end,
  },
}
