SPhone = SPhone or {}
SPhone.utils = SPhone.utils or {}

function SPhone.utils.formatDateNumber(str, length)
    local buffer = str
    if #str >= length then return str end
    for i = 1, length - 1 do
        buffer = "0" .. buffer
    end
    return buffer
end