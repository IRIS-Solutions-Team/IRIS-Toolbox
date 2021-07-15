% Type `web +databank/fieldNames.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function list = fieldNames(inputDb)

% >=R2019b
%(
arguments
    inputDb {validate.mustBeDatabank}
end
%)
% >=R2019b


if isa(inputDb, 'Dictionary')
    list = keys(inputDb);
else
    list = reshape(string(fieldnames(inputDb)), 1, [ ]);
end

end%

