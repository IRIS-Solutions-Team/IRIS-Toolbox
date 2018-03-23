function [s, empty, sz] = printSize(x)

if usejava('desktop')
    CHAR_TIMES = char(215);
else
    CHAR_TIMES = 'x';
end

sz = size(x);
s = sprintf(['%g', CHAR_TIMES], sz);
s(end) = ''; 

empty = '';
if any(sz==0)
    empty = 'Empty ';
end

end
