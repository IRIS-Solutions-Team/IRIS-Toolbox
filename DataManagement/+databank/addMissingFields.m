function db = addMissingFields(db, names, value)

% >=R2019b
%{
arguments
    db
    names (1, :) string
    value
end
%}
% >=R2019b

for n = textual.stringify(names)
    if isfield(db, n)
        continue
    end
    db.(n) = value;
end

end%

