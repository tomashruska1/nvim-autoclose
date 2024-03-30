local M = {}

function M.setup()
    local functions = require('autoclose.functions')

    vim.keymap.set('i', '[', function() functions.autoclose('[', ']') end, { noremap = true })
    vim.keymap.set('i', '(', function() functions.autoclose('(', ')') end, { noremap = true })
    vim.keymap.set('i', '{', function() functions.autoclose('{', '}') end, { noremap = true })
    vim.keymap.set('i', '"', function() functions.autoclose('"', '"') end, { noremap = true })
    vim.keymap.set('i', "'", function() functions.autoclose("'", "'") end, { noremap = true })

    vim.keymap.set('i', '<CR>', functions.format_braces, { noremap = true })
end

return M
