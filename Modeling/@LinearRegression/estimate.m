function [this, runningDatabank] = estimate(this, runningDatabank, range, varargin)
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
    addParameter(parser, 'RemoveMissing', false, @validate.logicalScalar);
end
parse(parser, this, runningDatabank, range, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

range = double(range);
[~, y, X, ~, inxBaseRangeColumns] = createModelData(this, runningDatabank, range);

numPages = size(X, 3);
numParameters = this.NumOfParameters;

% Preallocate space for results
this.Parameters = nan(1, numParameters, numPages);
this.Statistics.VarErrors = nan(1, numPages);
this.Statistics.CovParameters = nan(numParameters, numParameters, numPages);
fitted = nan(size(y));
errors = nan(size(y));

% Fixed terms on the RHS, add NaN for constant
fixed = [this.Explanatory.Fixed];
if this.Constant
    fixed = [fixed, NaN];
end

% Estimate parameter variants from individual data pages
inxMissing = false(1, numPages);
for v = 1 : numPages
    inxColumns = inxBaseRangeColumns;
    inxFiniteColumns = all(isfinite([X(:, :, v); y(:, :, v)]), 1);
    if opt.RemoveMissing
        inxColumns = inxColumns & inxFiniteColumns;
    elseif any(inxColumns & ~inxFiniteColumns)
        inxMissing(v) = true;
        continue
    end
    if ~any(inxColumns)
        continue
    end

    [beta, varErrors, covBeta] = hereGLSQ(y(:, inxColumns, v), X(:, inxColumns, v), fixed);

    this.Parameters(1, :, v) = beta;
    fitted(:, inxColumns, v) = beta*X(:, inxColumns, v);
    errors(:, inxColumns, v) = y(:, inxColumns, v) - fitted(:, inxColumns, v);
    this.Statistics.VarErrors(v) = varErrors;
    this.Statistics.CovParameters(:, :, v) = covBeta;
end

hereReportMissing( );

herePopulateDatabank( );

return


    function hereReportMissing( )
        if ~any(inxMissing)
            return
        end
        thisWarning  = { 'LinearRegression:MissingObservationInEstimationRange'
                         'Estimation range for the LinearRegression corrupted with NaN or Inf observations %s' };
        throw( exception.Base(thisWarning, 'warning'), ...
               exception.Base.alt2str(inxMissing, 'Page:', '%g') );
    end%


    function herePopulateDatabank( )
        errors = permute(errors(:, inxBaseRangeColumns, :), [2, 3, 1]);
        fitted = permute(fitted(:, inxBaseRangeColumns, :), [2, 3, 1]);

        errorsName = this.ErrorsName;
        fittedName = this.FittedName;

        startDate = DateWrapper(range(1));
        runningDatabank.(errorsName) = Series(startDate, errors);
        runningDatabank.(fittedName) = Series(startDate, fitted);
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

