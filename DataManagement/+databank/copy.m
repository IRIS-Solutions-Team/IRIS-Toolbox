function targetDatabank = copy(sourceDatabank, varargin)
% copy  Copy fields of source databank to target databank
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.copy');
    addRequired(pp, 'sourceDatabank', @validate.databank);
    addOptional(pp, 'sourceNames', @all, @(x) isequal(x, @all) || validate.list(x));
    addOptional(pp, 'targetDatabank', @empty, @(x) isequal(x, @empty) || validate.databank(x));
    addOptional(pp, 'targetNames', @auto, @(x) isequal(x, @auto) || validate.list(x));
end
parse(pp, sourceDatabank, varargin{:});
sourceNames = pp.Results.sourceNames;
targetDatabank = pp.Results.targetDatabank;
targetNames = pp.Results.targetNames;

%--------------------------------------------------------------------------

if isequal(sourceNames, @all)
    if isa(sourceDatabank, 'Dictionary')
        sourceNames = keys(sourceDatabank);
    else
        sourceNames = fieldnames(sourceDatabank);
    end
end
sourceNames = string(sourceNames);

if isequal(targetDatabank, @empty)
    if isa(sourceDatabank, 'Dictionary')
        targetDatabank = Dictionary( );
    elseif isstruct(sourceDatabank)
        targetDatabank = struct( );
    end
end

if isequal(targetNames, @auto)
    targetNames = sourceNames;
else
    targetNames = string(targetNames);
end

hereCheckDimensions( );

for i = 1 : numel(sourceNames)
    sourceName__ = sourceNames(i);
    targetName__ = targetNames(i);
    value = sourceDatabank.(char(sourceName__));
    if isa(targetDatabank, 'Dictionary')
        store(targetDatabank, targetName__, value);
    elseif isstruct(targetDatabank)
        targetDatabank.(char(targetName__)) = value;
    end
end

return


    function hereCheckDimensions( )
        if numel(sourceNames)~=numel(targetNames)
            targetDatabankError = { 'Databank:InvalidDimensionOfNames'
                          'Number of source names must match number of target names' };
            throw(exception.ParseTime(targetDatabankError, 'error'));
        end
    end%
end%

