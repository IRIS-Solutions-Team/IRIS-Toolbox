function [out_array,out_range,out_comments] = dbts2num(in_db,in_list,in_option)

if (isa(in_list,'char') && ~isempty(in_list) && in_list(1)=='*') || (isnumeric(in_list) && all(isinf(in_list)))
  in_list = dbobjects(in_db);
elseif isa(in_list,'char')
  in_list = {in_list};
end

x = [ ];
for k = 1 : length(in_list)
  x = [x,getfield(in_db,in_list{k})];
end

[out_array,out_range,out_comments] = ts2num(x,in_option);

return