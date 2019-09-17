function runningDatabank = simulate(this, runningDatabank, range, varargin)
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
    addParameter(parser, 'Dynamic', true, @validate.logicalScalar);
end
parse(parser, this, runningDatabank, range, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

range = double(range);
[plainData, y, X, e, inxBaseRangeColumns] = createModelData(this, runningDatabank, range);

e(~isfinite(e)) = 0;

numPages = size(X, 3);
firstColumn = find(inxBaseRangeColumns, 1);
lastColumn = find(inxBaseRangeColumns, 1, 'last');

% Simulate individual parameter variants
for v = 1 : numPages
    vthPlainLhs = plainData(1, :, v);
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
    plainData(1, :, v) = vthPlainLhs;
end

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
        startDate = DateWrapper(range(1));
        lhsNameInDatabank = this.LhsNameInDatabank;
        plainLhs = plainData(1, inxBaseRangeColumns, :);
        plainLhs = permute(plainLhs, [2, 3, 1]);
        runningDatabank.(lhsNameInDatabank) = Series(startDate, plainLhs);
    end%
end%

