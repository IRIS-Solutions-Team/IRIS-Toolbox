function [inout_s] = dbgen(in_list,in_names,in_expr,inout_s)

if isempty(inout_s)
  inout_s = struct( );
end

if ~isa(in_list,'cell') && all(isinf(in_list))
  in_list = dbobjects(inout_s);
end

n = length(in_list);
for ( k = 1 : n )
  name = db_newname(in_names,in_list{k},k);
  expr_k = strrep(in_expr,'#',in_list{k});
  x = evalin('caller',expr_k,'[]');
  if isempty(x)
    error(['Error in evaluating gen expression: ',expr_k]);
  else
    inout_s = setfield(inout_s,name,x);
  end
end

end