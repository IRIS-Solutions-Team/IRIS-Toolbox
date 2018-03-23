function varargout = dbdimretrieve(this, dimension, pos)
% dbdimretrieve  Retrieve specified slices in specified dimension from database entries.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

listOfFields = fieldnames(this);
if isempty(listOfFields)
    varargout{1} = this;
    return
end
numOfFields = length(listOfFields);
indexOfSuccess = false(1, numOfFields);

for i = 1 : numOfFields
    ithName = listOfFields{i};
    sizeOfField = size(this.(ithName));
    ndimsOfField = length(sizeOfField);
    if dimension>ndimsOfField
        sizeOfField(end+1:dimension) = 1;
    end
    reference = cell(1, ndimsOfField);
    reference(:) = {':'};
    if isequal(pos, 'end')
        reference{dimension} = sizeOfField(dimension);
    elseif sizeOfField(dimension)==1
        reference{dimension} = 1;
    else
        reference{dimension} = pos;
    end
    if isa(this.(ithName), 'tseries')
        try %#ok<TRYNC>
            this.(ithName) = this.(ithName){reference{:}};
            indexOfSuccess(i) = true;
        end
    elseif isnumeric(this.(ithName)) ...
            || islogical(this.(ithName)) ...
            || iscell(this.(ithName))
        try %#ok<TRYNC>
            this.(ithName) = this.(ithName)(reference{:});
            indexOfSuccess(i) = true;
        end
    end
end

if any(~indexOfSuccess)
    this = rmfield(this, listOfFields(~indexOfSuccess));
end
varargout{1} = this;

end
