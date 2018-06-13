function outputTable = table(this, query, varargin)
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
% * `Request` [ `'Parameters'` | `'Steady'` | `'SteadyLevel'` |
% `'SteadyGrowth'` | `'Std'` | `'Corr'` | `'NonzeroCorr'` ] - Requested
% values.
%
% 
% __Output Arguments__
%
% * `OutputTable` [ table ] - Table object with requested values.
%
%
% __Options__
%
% * `Diary=''` [ char | string ] - If `Diary=` is not empty, the table will
% be printed on the screen in the command window, and captured in a text
% file under this file name.
%
% * `WriteTable=''` [ char | string ] - If `WriteTable=` is not empty, the
% table will be exported to a text file under this file name using the
% standard `writetable( )` function.
%
%
% __Description__
%
%
% __Example__
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team


TYPE = @int8;

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('model.table');
    inputParser.addRequired('Model', @(x) isa(x, 'model'));
    inputParser.addRequired('Query', @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    inputParser.addParameter('WriteTable', '', @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
    inputParser.addParameter('Diary', '', @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
end
inputParser.parse(this, query, varargin{:});
opt = inputParser.Options;

%--------------------------------------------------------------------------

indexOfParameters = this.Quantity.Type==TYPE(4);
indexOfShocks = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);

if strcmpi(query, 'Steady')
    steadyLevel = table(this, 'SteadyLevel', varargin{:});
    steadyChange = table(this, 'SteadyGrowth', varargin{:});
    outputTable = [steadyLevel, steadyChange];
elseif strcmpi(query, 'SteadyLevel')
    values = this.Variant.Values;
    values = real(values);
    values = permute(values, [2, 3, 1]);
    names = this.Quantity.Name;
    outputTable = table(values, 'VariableNames', {'SteadyLevel'}, 'RowNames', names);
elseif any(strcmpi(query, 'SteadyGrowth'))
    namesOfAll = this.Quantity.Name;
    indexOfLog = this.Quantity.IxLog;
    values = this.Variant.Values;
    values = imag(values);
    values = permute(values, [2, 3, 1]);
    valuesDiff = values;
    valuesDiff(indexOfLog | indexOfParameters) = NaN;
    valuesRate = values;
    valuesRate(~indexOfLog | indexOfParameters) = NaN;
    outputTable = table( valuesDiff, valuesRate, ...
                         'VariableNames', {'SteadyDifference', 'SteadyRateOfChange'}, ...
                         'RowNames', namesOfAll );
elseif strcmpi(query, 'Parameters')
    values = this.Variant.Values;
    values = values(1, indexOfParameters, :);
    values = permute(values, [2, 3, 1]);
    namesOfParameters = this.Quantity.Name(indexOfParameters);
    outputTable = table( values, ...
                         'VariableNames', {'ParameterValue'}, ...
                         'RowNames', namesOfParameters );
elseif strcmpi(query, 'Std')
    namesOfStd = getStdNames(this.Quantity);
    numOfShocks = numel(namesOfStd);
    valuesOfStd = permute( this.Variant.StdCorr(1, 1:numOfShocks, :), [2, 3, 1] );
    outputTable = table( valuesOfStd, ...
                         'VariableNames', {'StdValue'}, ...
                         'RowNames', namesOfStd );
elseif strcmpi(query, 'Corr') || strcmpi(query, 'NonzeroCorr')
    namesOfCorr = getCorrNames(this.Quantity);
    numOfShocks = nnz(indexOfShocks);
    valuesOfCorr = permute( this.Variant.StdCorr(1, numOfShocks+1:end, :), [2, 3, 1] );
    if strcmpi(query, 'NonzeroCorr')
        indexOfNonzero = any(valuesOfCorr~=0, 2);
        namesOfCorr = namesOfCorr(indexOfNonzero);
        valuesOfCorr = valuesOfCorr(indexOfNonzero, :);
    end
    outputTable = table( valuesOfCorr, ...
                         'VariableNames', {'CorrValue'}, ...
                         'RowNames', namesOfCorr );
end

if ~isempty(opt.WriteTable)
    writetable(outputTable, opt.WriteTable);
end

if ~isempty(opt.Diary)
    if exist(opt.Diary, 'file')==2
        delete(opt.Diary);
    end
    diary(opt.Diary);
    disp(outputTable);
    diary off;
end

end%

