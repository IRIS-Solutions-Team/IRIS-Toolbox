function outputDatabank = residuals(this, inputDatabank, range, varargin)
% residuals  Evaluate residuals from LinearRegression
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
    addRequired(parser, 'range', @DateWrapper.validateProperRangeInput);
    % Options
    addParameter(parser, 'AddToDatabank', [ ], @(x) isequal(x, [ ]) || validate.databank(x));
    addParameter(parser, 'AppendPostsample', false, @validate.logicalScalar);
    addParameter(parser, 'AppendPresample', false, @validate.logicalScalar);
    addParameter(parser, 'OutputType', 'struct', @validate.databankType);
end
parse(parser, this, inputDatabank, range, varargin{:});
opt = parser.Options;

storeToDatabank = nargout>=1;

%--------------------------------------------------------------------------

range = double(range);
[plain, y, X, ~, inxBaseRangeColumns, extendedRange] = createModelData(this, inputDatabank, range);

numExtendedPeriods = size(X, 2);
numPages = size(X, 3);
numParameters = this.NumOfParameters;

% Preallocate space for results
fitted = nan(size(y));

% Estimate parameter variants from individual data pages
inxMissingColumns = false(1, numExtendedPeriods, numPages);
for v = 1 : numPages
    vthY = y(:, inxBaseRangeColumns, v);
    vthX = X(:, inxBaseRangeColumns, v);
    vthBeta = this.Parameters(:, :, v);
    fitted(:, inxBaseRangeColumns, v) = vthBeta*X(:, inxBaseRangeColumns, v);
    plain(end, inxBaseRangeColumns, v) = y(:, inxBaseRangeColumns, v) - fitted(:, inxBaseRangeColumns, v);
end

if storeToDatabank
    outputDatabank = createOutputDatabank(this, inputDatabank, extendedRange, plain, fitted, opt);
end

end%

