%{
% 
% # `databank.retrieve` ^^(+databank)^^
% 
% {== Retrieve selected fields from databank ==}
% 
% 
% ## Syntax 
% 
%     d = d * list
% 
% 
% ## Input arguments 
% 
% __`d`__ [ struct | Dictionary ]
% > 
% > Input database.
% > 
% 
% __`list`__ [ string ] 
% > 
% > List of entries that will be kept in the output database.
% > 
% 
% 
% ## Output arguments 
% 
% __`d`__ [ struct | Dictionary ] 
% > 
% > Output database where only the input entries that are in the `list`
% > are included.
% > 
% 
% 
% ## Options 
% 
% __`zzz=default`__ [ zzz | ___ ]
% > 
% > Description
% > 
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
% ```matlab
% ```
% 
%}
% --8<--


function outputDb = mtimes(inputDb, list)

list = string(list);
if isa(inputDb, 'Dictionary')
    outputDb = retrieve(inputDb, list);
else
    outputDb = rmfield(inputDb, setdiff(keys(inputDb), list));
end

end%

