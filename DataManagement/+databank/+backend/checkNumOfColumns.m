function [flag, invalidFields] = checkNumOfColumns( inputDatabank, ...
                                                    fieldsToCheckRequired, ...
                                                    fieldsToCheckOptional, ...
                                                    admissibleNumOfColumns )
% checkNumOfColumns  Check consistency of the number of data columns in databank time series
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('databank.checkNumOfColumns');
    inputParser.addRequired('InputDatabank', @isstruct);
    inputParser.addRequired('FieldsToCheckRequired', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addRequired('FieldsToCheckOptional', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addRequired('AdmissibleNumOfColumns', @(x) isnumeric(x) && all(round(x)==x) && all(x>=1));
end
inputParser.parse( inputDatabank, ...
                   fieldsToCheckRequired, ...
                   fieldsToCheckOptional, ...
                   admissibleNumOfColumns );
admissibleNumOfColumns = admissibleNumOfColumns(:)';

%--------------------------------------------------------------------------

fieldsToCheckRequired = cellstr(fieldsToCheckRequired);
fieldsToCheckOptional = cellstr(fieldsToCheckOptional);

numOfRequired = numel(fieldsToCheckRequired);
validRequired = true(1, numOfRequired);
for i = 1 : numel(fieldsToCheckRequired)
    name = fieldsToCheckRequired{i};
    if ~isfield(inputDatabank, name)
        validRequired(i) = false;
        continue
    end
    sizeOfField = size(inputDatabank.(name));
    if ~any(sizeOfField(2)==admissibleNumOfColumns)
        validRequired(i) = false;
        continue
    end
end

numOfOptional = numel(fieldsToCheckOptional);
validOptional = true(1, numOfOptional);
for i = 1 : numel(fieldsToCheckOptional)
    name = fieldsToCheckOptional{i};
    if ~isfield(inputDatabank, name)
        continue
    end
    sizeOfField = size(inputDatabank.(name));
    if ~any(sizeOfField(2)==admissibleNumOfColumns)
        validOptional(i) = false;
        continue
    end
end

flag = all(validRequired) && all(validOptional);
invalidFields = cell.empty(1, 0);
if ~flag
    invalidFields = [ fieldsToCheckRequired(~validRequired), ...
                      fieldsToCheckOptional(~validOptional) ];
end

end%
