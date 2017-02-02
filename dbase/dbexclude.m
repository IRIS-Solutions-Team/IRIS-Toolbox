function d = dbexclude(d,cond,varargin)

cond = strrep(cond,'"','''');

list = fieldnames(d).';
exclude = false(size(list));
for i = 1 : length(list)
   x = d.(list{i});
   name = list{i};
   try
      flag = eval(cond);
   catch
      flag = false;
   end
   exclude(i) = flag;
end

if any(exclude)
   d = rmfield(d,list(exclude));
end

end