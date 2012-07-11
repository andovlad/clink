--
-- Copyright (c) 2012 Martin Ridgers
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

--------------------------------------------------------------------------------
function get_dir_matches(prefix, mask)
    local has_matches = 0
    for _, dir in ipairs(clink.finddirs(mask)) do
        if not dir:find("^%.+$") then
            clink.add_match(prefix..dir)
            has_matches = has_matches + 1
        end
    end

    return has_matches
end

--------------------------------------------------------------------------------
function dir_match_generator(text, first, last)
    -- Only show directories if the command is 'dir', 'cd', or 'pushd'
    local leading = rl_line_buffer:sub(1, first - 1)
    local cmd = leading:match("^%s*([a-zA-Z]+)%s+")
    if not cmd then
        return false
    end

    -- Check it's a command that we only want to complete dirs for.
    cmd = cmd:lower()
    if cmd ~= "dir" and cmd ~= "cd" and cmd ~= "pushd" and cmd ~= "rd" and cmd ~= "rmdir" then
        return false
    end

    -- Strip off any path components that may be on text.
    local prefix = ""
    local i = text:find("[\\/:][^\\/:]*$")
    if i then
        prefix = text:sub(1, i)
    end

    -- Find dirs and add as matches.
    local has_matches = 0
    local mask = clink.lower(text).."*"
    has_matches = has_matches + get_dir_matches(prefix, mask)

    -- If readline's -/_ mapping is on, adjust mask and check for more matches.
    if clink.is_rl_variable_true("completion-map-case") then
        mask = mask:gsub("_", "-")
        has_matches = get_dir_matches(prefix, mask)
    end

    -- If there was no matches then add input as the match. DON'T tell readline
    -- it's a file. This will have it think completion is done.
    if has_matches == 0 then
        clink.add_match(text)
    else
        clink.matchesarefiles()
    end

    return true
end

--------------------------------------------------------------------------------
clink.register_match_generator(dir_match_generator, 50)