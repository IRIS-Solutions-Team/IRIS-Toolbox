function [runningData, YXEPG] = shockdb(this, runningData, range, varargin)
% shockdb  Create model-specific databank with random shocks
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     outputDatabank = shockdb(model, inputDatabank, range, ...)
%
%
% ## Input Arguments ##
%
% * `model` [ model ] - Model object.
%
% * `inputDatabank` [ struct | empty ] - Input databank to which shock time
% series will be added; if omitted or empty, a new databank will be
% created; if `inputDatabank` already contains shock time series, the data
% generated by `shockdb` will be added up with the existing data.
%
% * `range` [ numeric ] - Date range on which the shock time series will be
% generated and returned; if `inputDatabank` already contains shock time
% series going before or after `range`, these will be clipped down to
% `range` in the output databank.
%
%
% ## Output Arguments ##
%
% * `outputDabank` [ struct ] - Databank with newly generated shock time
% series added.
%
%
% ## Options ##
%
% * `NumOfDraws=@auto` [ numeric | `@auto` ] - Number of draws (i.e.
% columns) generated for each shock; if `@auto`, the number of draws is
% equal to the number of alternative parameter variants in the model `M`,
% or to the number of columns in shock series existing in the input
% databank, `InputData`.
%
% * `ShockFunc=@zeros` [ `@lhsnorm` | `@randn` | `@zeros` ] - Function used
% to generate random draws for new shock time series; if `@zeros`, the new
% shocks will simply be filled with zeros; the random numbers will be
% adjusted by the respective covariance matrix implied by the current model
% parameterization.
%
%
% ## Description ##
%
% Create a databank of time series for all model shocks.  The time series
% are generated using a specified function, `ShockFunc`.  The two typical
% cases are `ShockFunc=@zeros`, generating a zero time series for each
% shock, and `ShockFunc=@randn`, generating random shocks from a Normal
% distribution and scaled appropriately by the model shock covariance
% matrix.
% 
% If the input databank, `inputDatabank`, already contains some time series
% for some of the model shocks, the newly generated values will be added to
% these. All other databank entries will be preserved in the output
% databank unchanged.
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

TIME_SERIES_CONSTRUCTOR = iris.get('DefaultTimeSeriesConstructor');
TIME_SERIES_TEMPLATE = TIME_SERIES_CONSTRUCTOR( );

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('model.shockdb');
    addRequired(pp, 'Model', @(x) isa(x, 'model'));
    addRequired(pp, 'InputDatabank', @(x) isempty(x) || validate.databank(x));
    addRequired(pp, 'Range', @(x) validate.properRange(x) || isempty(x));
    addOptional(pp, 'NumOfDrawsOptional', @auto, @(x) isequal(x, @auto) || (isnumeric(x) && isscalar(x) && x==round(x) && x>=1));

    addParameter(pp, 'NumOfDraws', @auto, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
    addParameter(pp, 'OutputType', @auto, @(x) isequal(x, @auto) || validate.anyString(x, 'struct', 'Dictionary'));
    addParameter(pp, 'ShockFunc', @zeros, @(x) isa(x, 'function_handle'));
end
%)
opt = parse(pp, this, runningData, range, varargin{:});
numDrawsOptional = pp.Results.NumOfDrawsOptional;
if ~isequal(numDrawsOptional, @auto)
    opt.NumOfDraws = numDrawsOptional;
end
range = double(range);

runningData = databank.backend.ensureTypeConsistency(runningData, opt.OutputType);

%--------------------------------------------------------------------------

numQuantities = numel(this.Quantity.Name);
inxE = getIndexByType(this, 31, 32);
ne = sum(inxE);
nv = length(this);
numPeriods = numel(range);
namesShocks = this.Quantity.Name(inxE);
labelsOrNames = getLabelsOrNames(this.Quantity, inxE);

if isempty(runningData) || isequal(runningData, struct( ))
    E = zeros(ne, numPeriods);
else
    requiredNames = cell.empty(1, 0);
    optionalNames = namesShocks;
    allowedNumeric = string.empty(1, 0);
    allowedLog = string.empty(1, 0);
    context = "";
    databankInfo = checkInputDatabank( ...
        this, runningData, range ...
        , requiredNames, optionalNames ...
        , allowedNumeric, allowedLog ...
        , context ...
    );

    E = requestData( ...
        this, databankInfo, runningData ...
        , [requiredNames, optionalNames], range ...
    );
end
numPages = size(E, 3);

if isequal(opt.NumOfDraws, @auto)
    opt.NumOfDraws = max(nv, numPages);
end
checkNumOfDraws( );

numRuns = max([nv, numPages, opt.NumOfDraws]);
if numPages==1 && numRuns>1
    E = repmat(E, 1, 1, numRuns);
end

if isequal(opt.ShockFunc, @lhsnorm)
    S = lhsnorm(zeros(1, ne*numPeriods), eye(ne*numPeriods), numRuns);
else
    S = opt.ShockFunc(numRuns, ne*numPeriods);
end

for i = 1 : numRuns
    if i<=nv
        Omg = covfun.stdcorr2cov(this.Variant.StdCorr(:, :, i), ne);
        F = covfun.factorise(Omg);
    end
    E(:, :, i) = E(:, :, i) + F*reshape(S(i, :), ne, numPeriods);
end

if nargout==1
    if ~isempty(range)
        start = range(1);
    else
        start = NaN;
    end
    for i = 1 : ne
        name = namesShocks{i};
        e = permute(E(i, :, :), [2, 3, 1]);
        runningData.(name) = replace(TIME_SERIES_TEMPLATE, e, start, labelsOrNames(i));
    end
elseif nargout==2
    [minShift, maxShift] = getActualMinMaxShifts(this);
    numExtendedPeriods = numPeriods-minShift+maxShift;
    baseColumns = (1:numPeriods) - minShift;
    YXEPG = nan(numQuantities, numExtendedPeriods, numRuns);
    YXEPG(inxE, baseColumns, :) = E;
end

return


    function checkNumOfDraws( )
        if nv>1 && opt.NumOfDraws>1 && nv~=opt.NumOfDraws
            THIS_ERROR = { 'Model:NumOfDrawIncompatibleWithParams'
                           [ 'Option NumOfDraws= is not consistent with the number ', ...
                             'of alternative parameter variants in the model object' ] };
            throw( exception.Base(THIS_ERROR, 'error') );
        end
        
        if numPages>1 && opt.NumOfDraws>1 && numPages~=opt.NumOfDraws
            THIS_ERROR = { 'Model:NumOfDrawIncompatibleWithPages'
                           [ 'Option NumOfDraws= is not consistent with the number ', ...
                             'of alternative data pags in the input databank' ] };
            throw( exception.Base(THIS_ERROR, 'error') );
        end
        
        if numPages>1 && nv>1 && nv~=numPages
            THIS_ERROR = { 'Model:PagesIncompatibleWithParams'
                           [ 'The number of alternative data pages in the input databank ', ...
                             'is not consistent with the number ', ...
                             'of alternative parameterizations in the model object' ] };
            throw( exception.Base(THIS_ERROR, 'error') );
        end
    end%
end%

