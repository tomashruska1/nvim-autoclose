local M = {}


local characters = {
    [' '] = true,
    [')'] = true,
    [']'] = true,
    ['}'] = true,
    ['>'] = true,
    ['"'] = true,
    ["'"] = true,
    [';'] = true
}


local closing_chars = {
    ['['] = ']',
    ['('] = ')',
    ['{'] = '}'
}


local function indent_whitespace(new_line)
    if new_line:sub(-1) == ' ' then
        return new_line .. '    '
    elseif new_line:sub(-1) == '\t' then
        return new_line .. '\t'
    else
        return new_line .. '    '
    end
end


function M.get_cursor_position()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local row = cursor_pos[1]
    local col = cursor_pos[2]

    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    local line_len = #line

    local line_start = ""
    if col > 0 then
        line_start = line:sub(1, col)
    end

    local line_end = ""
    if col + 1 <= line_len then
        line_end = line:sub(col + 1)
    end

    return {
        row = row,
        col = col,
        line = line,
        line_start = line_start,
        line_end = line_end,
        virtcol = vim.fn.virtcol('.')
    }
end


-- @param open string
-- @param close string
function M.autoclose(open, close)
    local position = M.get_cursor_position()

    if #position.line_end > 0 then
        local following_char = position.line_end:sub(1, 1)

        if not characters[following_char] or close == following_char then
            close = ""
        end
    end

    local to_write = open .. close

    local command = string.format("normal! %dG%d|i%s", position.row, position.virtcol, to_write)

    vim.api.nvim_command(command)

    if close == "" then
        vim.api.nvim_win_set_cursor(0, { position.row, position.col + 1 })
    end
end


function M.format_braces()
    local position = M.get_cursor_position()

    if #position.line_start == 0 then -- no text before the cursor on the current line
        vim.api.nvim_command('normal! O')

        vim.api.nvim_win_set_cursor(0, { position.row + 1, position.col })

        return
    end

    local leading_whitespace = position.line_start:match('^%s*')

    local current = position.line_start:sub(#position.line_start, #position.line_start)
    local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

    if #position.line_end == 0 and (current == '[' or current == '{' or current == '(' or (filetype == 'python' and current == ':')) then
        local new_line = indent_whitespace(leading_whitespace)

        vim.api.nvim_buf_set_lines(0, position.row, position.row, true, { new_line })
        vim.api.nvim_win_set_cursor(0, { position.row + 1, #new_line })

        return
    end

    if (current ~= '[' and current ~= '(' and current ~= '{') or #position.line_end == 0 then
        vim.api.nvim_buf_set_lines(0, position.row - 1, position.row, true, { position.line_start, leading_whitespace .. position.line_end })
        vim.api.nvim_win_set_cursor(0, { position.row + 1, #leading_whitespace })

        return
    end

    local next = position.line_end:sub(1, 1)

    if next ~= closing_chars[current] then
        vim.api.nvim_buf_set_lines(0, position.row - 1, position.row, true, { position.line_start, leading_whitespace .. position.line_end })
        vim.api.nvim_win_set_cursor(0, { position.row + 1, #leading_whitespace })

        return
    end

    local new_line = indent_whitespace(leading_whitespace)

    vim.api.nvim_buf_set_lines(0, position.row - 1, position.row, true, { position.line_start, new_line, leading_whitespace .. position.line_end })

    vim.api.nvim_win_set_cursor(0, { position.row + 1, #new_line })
end


return M
