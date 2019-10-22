function [this, outputDatabank] = estimate(this, inputDatabank, range, varargin)
% estimate  Estimate parameters of LinearRegression
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('LinearRegression.estimate');
    % Required arguments
    addRequired(parser, 'linearRegression', @(x) isa(x, 'LinearRegression'));
    addRequired(parser, 'inputDatabank', @validate.databank);
    addRequired(parser, 'estimationRange', @DateWrapper.validateProperRangeInput);
    % Options
    addParameter(parser, 'AddToDatabank', [ ], @(x) isequal(x, [ ]) || validate.databank(x));
    addParameter(parser, 'AppendPostsample', false, @validate.logicalScalar);
    addParameter(parser, 'AppendPresample', false, @validate.logicalScalar);
    addParameter(parser, 'OutputType', 'struct', @validate.databankType);
    addParameter(parser, 'MissingObservations', 'Warning', @(x) validate.anyString(x, 'Error', 'Warning', 'Silent'));
end
parse(parser, this, inputDatabank, range, varargin{:});
opt = parser.Options;

storeToDatabank = nargout>=2;

%--------------------------------------------------------------------------

range = double(range);
[plain, y, X, ~, inxBaseRangeColumns, extendedRange] = createModelData(this, inputDatabank, range);

numExtendedPeriods = size(X, 2);
numPages = size(X, 3);
numParameters = this.NumOfParameters;

% Preallocate space for results
this.Parameters = nan(1, numParameters, numPages);
this.Statistics.VarErrors = nan(1, numPages);
this.Statistics.StdParameters = zeros(1, numParameters, numPages);
this.Statistics.CovParameters = nan(numParameters, numParameters, numPages);
fitted = nan(size(y));

% Fixed terms on the RHS, add NaN for intercept
fixed = [this.Explanatory.Fixed];
if this.Intercept
    fixed = [fixed, NaN];
end

% Estimate parameter variants from individual data pages
inxMissingColumns = false(1, numExtendedPeriods, numPages);
for v = 1 : numPages
    inxColumns = inxBaseRangeColumns;
    inxFiniteColumns = all(isfinite([X(:, :, v); y(:, :, v)]), 1);
    inxMissingColumns(1, :, v) = inxColumns & ~inxFiniteColumns;
    if strcmpi(opt.MissingObservations, 'Warning') || strcmpi(opt.MissingObservations, 'Silent')
        inxColumns = inxColumns & inxFiniteColumns;
    elseif any(inxMissingColumns(1, :, v))
        continue
    end
    if ~any(inxColumns)
        continue
    end

    vthY = y(:, inxColumns, v);
    vthX = X(:, inxColumns, v);
    [beta, varErrors, covBeta] = hereGLSQ(vthY, vthX, fixed);

    this.Parameters(1, :, v) = beta;
    fitted(:, inxColumns, v) = beta*X(:, inxColumns, v);
    plain(end, inxColumns, v) = y(:, inxColumns, v) - fitted(:, inxColumns, v);
    this.Statistics.VarErrors(v) = varErrors;
    this.Statistics.StdParameters(:, :, v) = reshape(sqrt(diag(covBeta)), 1, [ ]);
    this.Statistics.CovParameters(:, :, v) = covBeta;
end

hereReportMissing( );

if storeToDatabank
    outputDatabank = createOutputDatabank(this, inputDatabank, extendedRange, plain, fitted, opt);
end

return


    function hereReportMissing( )
        if ~any(inxMissingColumns(:)) || strcmpi(opt.MissingObservations, 'Silent')
            return
        end
        report = DateWrapper.reportMissingPeriodsAndPages(range, inxMissingColumns(1, inxBaseRangeColumns, :));
        if strcmpi(opt.MissingObservations, 'Warning')
            action = 'adjusted to exclude';
        else
            action = 'contaminated with';
        end
        thisWarning  = { 'LinearRegression:MissingObservationInEstimationRange'
                         'LinearRegression(%1) estimation range %2 NaN or Inf observations [Variant|Page:%g]: %s' };
        throw( exception.Base(thisWarning, opt.MissingObservations), ...
               join(this.LhsNamesInDatabank, ','), action, report{:} );
    end%
end%


%
% Local Functions
%


function [beta, varErrors, covBeta] = hereGLSQ(y, X, fixed)
    numParameters = numel(fixed);
    beta = fixed;
    covBeta = zeros(numParameters, numParameters);
    inxFixed = ~isnan(fixed);
    if any(inxFixed)
        y = y - fixed(inxFixed)*X(inxFixed, :);
        X = X(~inxFixed, :);
    end
    [beta__, ~, varErrors, covBeta__] = lscov(transpose(X), transpose(y));
    beta(~inxFixed) = transpose(beta__);
    covBeta(~inxFixed, ~inxFixed) = covBeta__;
end%

