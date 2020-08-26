%{
% databank.copy  Copy fields of source databank to target databank
%
% Syntax
%--------------------------------------------------------------------------
%
%     targetDb = databank.copy(sourceDb, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`sourceDb`__ [ struct | Dictionary ]
%
%     Source databank from which some (or all) fields will be copied over
%     to the `targetDb`.
%
%
% Options
%--------------------------------------------------------------------------
%
% __`SourceNames=@all`__ [ `@all` | cellstr | string ]
%
%     List of fieldnames to be copied over from the `sourceDb` to the
%     `targetDb`; `@all` means all fields existing in the `sourceDb` will
%     be copied.
%
%
% __`TargetDb=@empty`__ [ `@empty` | struct | Dictionary ]
%
%     Target databank to which some (or all) fields form the `sourceDb`
%     will be copied over; `@empty` means a new empty databank will be
%     created of the same type as the `sourceDb` (either a struct or a
%     Dictionary).
% 
%
% __`TargetNames=@auto`__ [ cellstr | string | function_handle]
% 
%     Names under which the fields from the `sourceDb` will be stored in
%     the `targetDb`; `@auto` means the `TargetNames` will be simply the
%     same as the `SourceNames`; if `TargetNames` is a function, the target
%     names will be created by applying this function to each of
%     the `SourceNames`.
%
%
% __`Transform=[ ]`__ [ empty | function_handle ]
%
%     Transformation function applied to each of the fields being copied
%     over from the `sourceDb` to the `targetDb`; if empty, no
%     transformation is performed.
%
%
% __`WhenTransformFails='Error'`__ [ `'Error'` | `'Warning'` | `'Silence'` ]
%
%     Action to be taken if the transformation function `Transform=`
%     evaluates to an error when applied to one or more fields of the source
%     databank.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`targetDb`__ [ struct | Dictionary ]
% 
%     Target databank to which some (or all) fields from the `sourceDb`
%     will be copied over.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%
% See also databank.apply, databank.batch
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function targetDb = copy(sourceDb, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.copy');
    addRequired(pp, 'sourceDb', @validate.databank);

    addParameter(pp, 'SourceNames', @all, @(x) isequal(x, @all) || validate.list(x));
    addParameter(pp, 'TargetDb', @empty, @(x) isequal(x, @empty) || validate.databank(x));
    addParameter(pp, 'TargetNames', @auto, @(x) isequal(x, @auto) || validate.list(x) || isa(x, 'function_handle'));
    addParameter(pp, 'Transform', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
    addParameter(pp, 'WhenTransformFails', 'Error', @(x) validate.anyString(x, 'Error', 'Warning'));
end
%)
opt = parse(pp, sourceDb, varargin{:});
sourceNames = opt.SourceNames;
targetNames = opt.TargetNames;
transform = opt.Transform;

%--------------------------------------------------------------------------

%
% Resolve source names
%
sourceNames = hereResolveSourceNames( );

%
% Resolve target databank
%
targetDb = hereResolveTargetDb( );

%
% Resolve target names
%
targetNames = hereResolveTargetNames( );

numSourceNames = numel(sourceNames);
hereCheckDimensions( );

inxSuccess = true(1, numSourceNames);
for i = 1 : numSourceNames
    sourceName__ = sourceNames(i);
    targetName__ = targetNames(i);
    value = sourceDb.(char(sourceName__));
    if ~isempty(transform)
        try
            value = transform(value);
        catch
            inxSuccess(i) = false;
            continue
        end
    end
    if isa(targetDb, 'Dictionary')
        store(targetDb, targetName__, value);
    elseif isstruct(targetDb)
        targetDb.(char(targetName__)) = value;
    end
end

if any(~inxSuccess)
    hereThrowTransformFailed( );
end

return

    function sourceNames = hereResolveSourceNames( )
        sourceNames = opt.SourceNames;
        if isequal(sourceNames, @all)
            if isa(sourceDb, 'Dictionary')
                sourceNames = keys(sourceDb);
            else
                sourceNames = fieldnames(sourceDb);
            end
        end
        sourceNames = string(sourceNames);
    end%


    function targetDb = hereResolveTargetDb( )
        targetDb = opt.TargetDb;
        if isequal(targetDb, @empty)
            if isa(sourceDb, 'Dictionary')
                targetDb = Dictionary( );
            elseif isstruct(sourceDb)
                targetDb = struct( );
            end
        end
    end%


    function targetNames = hereResolveTargetNames( )
        targetNames = opt.TargetNames;
        if isequal(targetNames, @auto)
            targetNames = sourceNames;
        elseif isa(targetNames, 'function_handle')
            targetNames = arrayfun(targetNames, sourceNames);
        else
            targetNames = string(targetNames);
        end
    end%


    function hereCheckDimensions( )
        numTargetNames = numel(targetNames);
        if numSourceNames~=numTargetNames
            thisError = [
                "Databank:InvalidDimensionOfNames"
                "Number of source names must match number of target names: %s"
            ];
            report = numSourceNames + "~=" + numTargetNames;
            throw(exception.ParseTime(thisError, 'error'), report);
        end
    end%


    function hereThrowTransformFailed( )
        thisError = [
            "Databank:TransformFailed"
            "Transformation function failed when applied to this source databank field: %s"
        ];
        throw(exception.Base(thisError, opt.WhenTransformFails), sourceNames(~inxSuccess));
    end%
end%


