% keys  List of keys in a databank (associative array)
%

function list = keys(inputDb)

if isa(inputDb, 'Dictionary')
    list = keys(inputDb);
elseif isstruct(inputDb)
    list = reshape(string(fieldnames(inputDb)), 1, [ ]);
else
    list = reshape(string(keys(inputDb)), 1, [ ]);
end

end%

