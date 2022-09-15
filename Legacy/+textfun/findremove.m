function [flag,s] = findremove(s,x)
n = length(s);
s = strrep(s,x,'');
flag = length(s) < n;
end
