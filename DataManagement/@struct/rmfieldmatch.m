function s = rmfieldmatch(s,pattern)

list = fieldnames(s);
index = textfun.matchindex(list,pattern);
s = rmfield(s,list(index));

end