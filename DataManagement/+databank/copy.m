function targetDatabank = copy(sourceDatabank, varargin)
% copy  Copy fields of source databank to target databank
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.copy');
    addRequired(parser, 'sourceDatabank', @validate.databank);
    addOptional(parser, 'sourceNames', @all, @(x) isequal(x, @all) || validate.list(x));
    addOptional(parser, 'targetDatabank', @empty, @(x) isequal(x, @empty) || validate.databank(x));
    addOptional(parser, 'targetNames', @auto, @(x) isequal(x, @auto) || validate.list(x));
end
parse(parser, sourceDatabank, varargin{:});
sourceNames = parser.Results.sourceNames;
targetDatabank = parser.Results.targetDatabank;
targetNames = parser.Results.targetNames;

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
    ithSourceName = sourceNames(i);
    ithTargetName = targetNames(i);
    if isa(sourceDatabank, 'Dictionary')
        value = retrieve(sourceDatabank, ithSourceName);
    elseif isstruct(sourceDatabank)
        value = getfield(sourceDatabank, char(ithSourceName));
    end
    if isa(targetDatabank, 'Dictionary')
        store(targetDatabank, ithTargetName, value);
    elseif isstruct(targetDatabank)
        targetDatabank = setfield(targetDatabank, char(ithTargetName), value);
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

