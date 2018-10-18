function outputTable = table(this, request, varargin)
% table  Extract requested values from model to table
%
% __Syntax__
%
%     OutputTable = table(Model, Request, ...)
%
%
% __Input Arguments__
%
% * `Model` [ model ] - Model object.
%
% * `Request` [ char ] - Requested values; see Description for the list of
% valid requests.
%
% 
% __Output Arguments__
%
% * `OutputTable` [ table ] - Table object with requested values.
%
%
% __Options__
%
% * `Compare=false` [ `true` | `false` ] - Compare reported values by
% including a difference or percent difference column for the second and
% furthere parameterizations; only works for models with multiple parameter
% variants.
%
% * `Diary=''` [ char | string ] - If `Diary=` is not empty, the table will
% be printed on the screen in the command window, and captured in a text
% file under this file name.
%
% * `ShowDescription=false` [ `true` | `false` | numeric ] - Add an extra
% column with the descriptions of the variables (from the model file); if a
% number, a description column will be shown abbreviated not to exceed this
% length.
%
% * `WriteTable=''` [ char | string ] - If not empty, the table will be
% exported to a text or spreadsheet file under this file name using the
% standard `writetable( )` function.
%
%
% __Description__
%
% The `Request` can be one of the following:
%
% * ``
%
% __Example__
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.table');
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addRequired('Request', @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter('Compare', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Diary', '', @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter('ShowDescription', false, @(x) isequal(x, true) || isequal(x, false) || (isnumeric(x) && isscalar(x) && x>0 && x==round(x)));
    parser.addParameter('ShowLog', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('WriteTable', '', @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
end
parser.parse(this, request, varargin{:});
opt = parser.Options;

nv = numel(this.Variant);
if opt.Compare && nv<=1
    throw( exception.Base('Model:CannotCompareTable', 'error') );
end

%--------------------------------------------------------------------------

inxOfParameters = this.Quantity.Type==TYPE(4);
inxOfShocks = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);

if strcmpi(request, 'Steady')
    steadyLevel = table(this, 'SteadyLevel', varargin{:}, 'Compare=', false);
    steadyChange = table(this, 'SteadyGrowth', varargin{:}, 'Compare=', false);
    outputTable = [steadyLevel, steadyChange];
    inxOfLog = this.Quantity.IxLog; 


elseif strcmpi(request, 'SteadyLevel')
    values = this.Variant.Values;
    values = real(values);
    values = permute(values, [2, 3, 1]);
    names = this.Quantity.Name;
    outputTable = table(values, 'VariableNames', {'SteadyLevel'}, 'RowNames', names);
    inxOfLog = this.Quantity.IxLog; 


elseif any(strcmpi(request, {'SteadyGrowth', 'SteadyChange'}))
    namesOfAll = this.Quantity.Name;
    inxOfLog = this.Quantity.IxLog;
    values = this.Variant.Values;
    values = imag(values);
    values = permute(values, [2, 3, 1]);
    valuesDiff = values;
    valuesDiff(inxOfLog | inxOfParameters, :) = NaN;
    valuesRate = values;
    valuesRate(~inxOfLog | inxOfParameters, :) = NaN;
    outputTable = table( valuesDiff, valuesRate, ...
                         'VariableNames', {'SteadyDifference', 'SteadyRateOfChng'}, ...
                         'RowNames', namesOfAll );
    inxOfLog = this.Quantity.IxLog; 


elseif strcmpi(request, 'Parameters')
    values = this.Variant.Values;
    values = values(1, inxOfParameters, :);
    values = permute(values, [2, 3, 1]);
    namesOfParameters = this.Quantity.Name(inxOfParameters);
    outputTable = table( values, ...
                         'VariableNames', {'ParameterValue'}, ...
                         'RowNames', namesOfParameters );
    inxOfLog = false(size(values, 1), 1);


elseif strcmpi(request, 'Std')
    namesOfStd = getStdNames(this.Quantity);
    numOfShocks = numel(namesOfStd);
    valuesOfStd = permute( this.Variant.StdCorr(1, 1:numOfShocks, :), [2, 3, 1] );
    outputTable = table( valuesOfStd, ...
                         'VariableNames', {'StdValues'}, ...
                         'RowNames', namesOfStd );
    inxOfLog = false(size(valuesOfStd, 1), 1);


elseif strcmpi(request, 'Corr') || strcmpi(request, 'NonzeroCorr')
    namesOfCorr = getCorrNames(this.Quantity);
    numOfShocks = nnz(inxOfShocks);
    valuesOfCorr = permute( this.Variant.StdCorr(1, numOfShocks+1:end, :), [2, 3, 1] );
    if strcmpi(request, 'NonzeroCorr')
        inxOfNonzero = any(valuesOfCorr~=0, 2);
        namesOfCorr = namesOfCorr(inxOfNonzero);
        valuesOfCorr = valuesOfCorr(inxOfNonzero, :);
    end
    outputTable = table( valuesOfCorr, ...
                         'VariableNames', {'CorrValues'}, ...
                         'RowNames', namesOfCorr );
    inxOfLog = false(size(valuesOfCorr, 1), 1);


elseif any(strcmpi(request, {'Roots', 'AllRoots', 'EigenValues', 'AllEigenValues'}))
    values = get(this, 'Roots');
    values = values(:);
    outputTable = table( values, abs(values), ...
                         'VariableNames', {'AllRoots', 'Magnitudes'} );
    inxOfLog = false(size(values, 1), 1);


elseif any(strcmpi(request, {'StableRoots', 'StableEigenValues'}))
    values = get(this, 'StableRoots');
    values = values(:);
    outputTable = table( values, abs(values), ...
                         'VariableNames', {'StableRoots', 'Magnitudes'} );
    inxOfLog = false(size(values, 1), 1);


elseif any(strcmpi(request, {'UnstableRoots', 'UnstableEigenValues'}))
    values = get(this, 'UnstableRoots');
    values = values(:);
    outputTable = table( values, abs(values), ...
                         'VariableNames', {'UnstableRoots', 'Magnitudes'} );
    inxOfLog = false(size(values, 1), 1);


elseif any(strcmpi(request, {'UnitRoots', 'UnitEigenValues'}))
    values = get(this, 'UnitRoots');
    values = values(:);
    outputTable = table( values, abs(values), ...
                         'VariableNames', {'UnitRoots', 'Magnitudes'} );
    inxOfLog = false(size(values, 1), 1);

else
    throw( exception.Base('Model:TableInvalidRequest', 'error'), ...
           request );

end

% Add comparison columns for each parameterization
if opt.Compare
    outputTable = addCompareColumns(this, outputTable, inxOfLog);
end

% Add description and log columns last so that it does not interfere with
% compare columns
if opt.ShowLog
    outputTable = addLogColumn(this, outputTable, inxOfLog);
end
if ~isequal(opt.ShowDescription, false)
    outputTable = addDescriptionColumn(this, outputTable, opt.ShowDescription);
end

% Write table to text or spreadsheet file
if ~isempty(opt.WriteTable)
    writetable(outputTable, opt.WriteTable);
end

% Print table to screen and capture output in diary
if ~isempty(opt.Diary)
    if exist(opt.Diary, 'file')==2
        delete(opt.Diary);
    end
    diary(opt.Diary);
    disp(outputTable);
    diary off;
end

end%


%
% Local Functions
%


function outputTable = addCompareColumns(this, outputTable, inxOfLog)
    list = outputTable.Properties.VariableNames;
    for i = 1 : numel(list)
        name = list{i};
        newName = ['Compare', name];
        values = outputTable.(name);
        firstColumn = values(:, 1);
        newValues = nan(size(values, 1), size(values, 2));
        newValues(~inxOfLog, :) = bsxfun( @minus, ...
                                          values(~inxOfLog, :), ...
                                          firstColumn(~inxOfLog, :) );
        newValues(inxOfLog, :)  = bsxfun( @rdivide, ...
                                          values(inxOfLog, :), ...
                                          firstColumn(inxOfLog, :) );
        outputTable = addvars( outputTable, newValues, ...
                               'NewVariableNames', newName );
    end
end%




function outputTable = addLogColumn(this, outputTable, inxOfLog)
    list = outputTable.Properties.RowNames;
    logColumn = inxOfLog(:);
    outputTable = addvars( outputTable, logColumn, ...
                           'Before', 1, ...
                           'NewVariableNames', 'Log' );
end%




function outputTable = addDescriptionColumn(this, outputTable, userLength)
    if ~isnumeric(userLength)
        userLength = Inf;
    end
    rowNames = outputTable.Properties.RowNames;
    descriptStruct = get(this, 'Description');
    descriptColumn = cell(size(rowNames));
    descriptColumn = cellfun( @(name) abbreviate(descriptStruct.(name), userLength), ...
                              rowNames, ...
                              'UniformOutput', false );
    outputTable = addvars( outputTable, descriptColumn, ...
                           'Before', 1, ...
                           'NewVariableNames', 'Description' );
    return


    function c = abbreviate(c, maxLength)
        ELLIPSIS = iris.get('Ellipsis');
        if ischar(c)
            if length(c)>maxLength
                c = [c(1:maxLength), ELLIPSIS];
            end
        elseif isa(c, 'string')
            if strlength(c)>maxLength
                c = replaceBetween(c, maxLength+1, strlength(c), ELLIPSIS);
            end
        end
    end%
end%

