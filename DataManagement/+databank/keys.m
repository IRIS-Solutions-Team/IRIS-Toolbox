% keys  List of keys in a databank (associative array)
%

function list = keys(inputDb)

if isstruct(inputDb)
    list = reshape(string(fieldnames(inputDb)), 1, [ ]);
elseif isa(inputDb, 'Dictionary')
    list = keys(inputDb);
else
    list = reshape(string(keys(inputDb)), 1, [ ]);
end

end%

