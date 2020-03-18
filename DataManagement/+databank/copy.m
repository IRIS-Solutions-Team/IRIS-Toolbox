function targetDb = copy(sourceDb, varargin)
% copy  Copy fields of source databank to target databank
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     targetDb = databank.copy(sourceDb, ~sourceNames, ~targetDb, ~targetNames)
%
%
% ## Input Arguments ##
%
%
% __`sourceDb`__ [ struct | Dictionary ]
% >
% Source databank from which some (or all) fields will be copied over to
% the `targetDb`.
%
%
% __`sourceNames`__ [ cellstr | string ]
% >
% List of fieldnames to be copied over from the `sourceDb` to the
% `targetDb`; if omitted, all fields existing in the `sourceDb` will be
% copied.
%
%
% __`~targetDb`__ [ struct | Dictionary ]
% >
% Target databank to which some (or all) fields form the `sourceDb` will be
% copied over; if omitted, a new empty databank will be created of the
% same type as the `sourceDb`.
% 
%
% __`~targetNames`__ [ cellstr | string ]
% >
% Names under which the fields from the `sourceDb` will be stored in the
% `targetDb`; if omitted, the names will remain unchanged from the
% `sourceDb`.
%
%
% ## Output Arguments ##
%
%
% __`targetDb`__ [ struct | Dictionary ]
% >
% Target databank to which some (or all) fields from the `sourceDb` will be
% copied over.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.copy');
    addRequired(pp, 'sourceDb', @validate.databank);
    addOptional(pp, 'sourceNames', @all, @(x) isequal(x, @all) || validate.list(x));
    addOptional(pp, 'targetDb', @empty, @(x) isequal(x, @empty) || validate.databank(x));
    addOptional(pp, 'targetNames', @auto, @(x) isequal(x, @auto) || validate.list(x));
end
parse(pp, sourceDb, varargin{:});
sourceNames = pp.Results.sourceNames;
targetDb = pp.Results.targetDb;
targetNames = pp.Results.targetNames;

%--------------------------------------------------------------------------

if isequal(sourceNames, @all)
    if isa(sourceDb, 'Dictionary')
        sourceNames = keys(sourceDb);
    else
        sourceNames = fieldnames(sourceDb);
    end
end
sourceNames = string(sourceNames);

if isequal(targetDb, @empty)
    if isa(sourceDb, 'Dictionary')
        targetDb = Dictionary( );
    elseif isstruct(sourceDb)
        targetDb = struct( );
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
    value = sourceDb.(char(sourceName__));
    if isa(targetDb, 'Dictionary')
        store(targetDb, targetName__, value);
    elseif isstruct(targetDb)
        targetDb.(char(targetName__)) = value;
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

