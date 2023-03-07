%{
% 
% # `databank.addMissingFields` ^^(+databank)^^
% 
% {== Create fields missing from a list, and assign them a default value ==}
% 
% 
% ## Syntax
% 
%     db = databank.addMissingFields(db, names, value)
% 
% 
% ## Input arguments
% 
% __`db`__ [ struct | Dictionary ]
% > 
% > Input databank that will be checked for `names`, and new fields will be
% > created for the names missing, assigned a default `value`.
% > 
% 
% __`names`__ [ string ]
% > 
% > List of field names; any field listed in `names` that does not exist in
% > the `db` will be created in `db` and assigned the default `value`.
% > 
% 
% __`values`__ [ * ]
% > 
% > A default value for fields that are missing from the `names`.
% > 
% 
% 
% ## Output arguments
% 
% __`db`__ [ struct | Dictionary ]
% > 
% > Output databank will all the `names` guaranteed to exist in it.
% > 
% 
% 
% ## Description
% 
% 
% ## Examples
% 
% Make sure that field names "a", "b", and "c" all exist in a databank; if
% not, create them and assign `NaN`:
% 
% ```matlab
% d = struct();
% d.a = 1;
% d = databank.addMissingFields(d, ["a", "b", "c"], NaN);
% ```
% 
% 
%}
% --8<--


function db = addMissingFields(db, names, value)

% >=R2019b
%(
arguments
    db
    names (1, :) string
    value
end
%)
% >=R2019b

for n = textual.stringify(names)
    if isfield(db, n)
        continue
    end
    db.(n) = value;
end

end%

