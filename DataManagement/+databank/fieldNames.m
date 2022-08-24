function list = fieldNames(inputDb)

% >=R2019b
%{
arguments
    inputDb {validate.mustBeDatabank}
end
%}
% >=R2019b


if isa(inputDb, 'Dictionary')
    list = keys(inputDb);
else
    list = reshape(string(fieldnames(inputDb)), 1, [ ]);
end

end%

