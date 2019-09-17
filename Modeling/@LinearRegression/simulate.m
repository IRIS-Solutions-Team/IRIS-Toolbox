function outputDatabank = simulate(this, inputDatabank, range, varargin)
% simulate  Simulate LinearRegression
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
    addRequired(parser, 'simulationRange', @DateWrapper.validateProperRangeInput);
    % Options
    addParameter(parser, 'AddToDatabank', [ ], @(x) isequal(x, [ ]) || validate.databank(x));
    addParameter(parser, 'AppendPostsample', false, @validate.logicalScalar);
    addParameter(parser, 'AppendPresample', false, @validate.logicalScalar);
    addParameter(parser, 'OutputType', 'struct', @validate.databankType);
    addParameter(parser, 'MissingObservations', 'Warning', @(x) validate.anyString(x, 'Error', 'Warning', 'Silent'));
    addParameter(parser, 'Dynamic', true, @validate.logicalScalar);
end
parse(parser, this, inputDatabank, range, varargin{:});
opt = parser.Options;

storeToDatabank = nargout>=1;

%--------------------------------------------------------------------------

range = double(range);
[plain, y, X, e, inxBaseRangeColumns, extendedRange] = createModelData(this, inputDatabank, range);
numExtendedPeriods = size(y, 2);

e(~isfinite(e)) = 0;

numPages = size(X, 3);
firstColumn = find(inxBaseRangeColumns, 1);
lastColumn = find(inxBaseRangeColumns, 1, 'last');

% Simulate individual parameter variants
for v = 1 : numPages
    vthPlainLhs = plain(this.PosOfLhsNames, :, v);
    vthY = y(:, :, v);
    vthX = X(:, :, v);
    vthE = e(:, :, v);
    vthBeta = this.Parameters(1, :, v);
    if opt.Dynamic
        for t = firstColumn : lastColumn
            vthY(:, t) = vthBeta*vthX(:, t) + vthE(:, t);
            vthPlainLhs = updatePlainLhs(this.Dependent, vthPlainLhs, vthY, t);
            if t<lastColumn
                vthX = updateOwnExplanatory(this.Explanatory, vthX, vthPlainLhs, t+1);
            end
        end
    else
        t = find(inxBaseRangeColumns);
        vthY(:, t) = vthBeta*vthX(:, t) + e(:, t);
        vthPlainLhs = updatePlainLhs(this.Dependent, vthPlainLhs, vthY, t);
    end
    plain(this.PosOfLhsNames, :, v) = vthPlainLhs;
end

%
% Detect and report NaN or Inf values in LHS variable
%
inxMissing = false(this.NumOfLhsNames, numExtendedPeriods, numPages);
inxMissing(:, inxBaseRangeColumns, :) = ~isfinite(plain(this.PosOfLhsNames, inxBaseRangeColumns, :));
hereReportMissing( );

%
% Create output databank with LHS, RHS and errors names
%
if storeToDatabank
    outputDatabank = createOutputDatabank(this, inputDatabank, extendedRange, plain, [ ], opt);
end

return

    function hereReportMissing( )
        if ~any(inxMissing) || strcmpi(opt.MissingObservations, 'Silent')
            return
        end
        report = DateWrapper.reportMissingPeriodsAndPages(range, inxMissing(1, inxBaseRangeColumns, :));
        thisWarning  = { 'LinearRegression:MissingObservationInEstimationRange'
                         'Simulation of LinearRegression(%1) corrupted with NaN or Inf observations [Variant|Page:%g]: %s' };
        throw(exception.Base(thisWarning, opt.MissingObservations), this.LhsNameInDatabank, report{:});
    end%
end%

