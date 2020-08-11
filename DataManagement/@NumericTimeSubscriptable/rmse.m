function [rmse, error] = rmse(actual, prediction, varargin)
% rmse  Calculate RMSE for given observations and predictions
%{
% Syntax
%--------------------------------------------------------------------------
%
%
%     [rmse, error] = rmse(inputSeries, prediction, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% 
% __`actual`__ [ Series ] 
%
%     Input time series with actual observations.
%
%
% __`prediction`__ [ Series ]
%
%     Input time series with predictions, possibly including multiple
%     prediction horizons in individual columns; this is typically the
%     outcome of running a Kalman filter with the option `Ahead=`.
%
%
% Options
%--------------------------------------------------------------------------
%
%
% __`Range=Inf`__ [ DateWrapper | `Inf` ]
%
%     Date range on which the prediction errors will be calculated; `Inf`
%     means all observations available will be included in the
%     calculations.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`rootMSE`__ [ numeric ]
%
%     Numeric array with root mean squared errors for each column of the
%     `prediction` time series.
%
%
% __`error`__ [ Series ] -
%
%     Time series with prediction errors from which the RMSEs are
%     calculated; `error` is simply the difference between `actual` and the
%     individual columns in `prediction`.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('@Series/rmse');
    addRequired(pp, 'actual', @(x) isa(x, 'NumericTimeSubscriptable') && ndims(x) == 2 && size(x, 2) == 1); %#ok<ISMAT>
    addRequired(pp, 'prediction', @(x) isa(x, 'NumericTimeSubscriptable'));
    addOptional(pp, 'legacyRange', Inf, @DateWrapper.validateRangeInput);
    addParameter(pp, 'Range', Inf, @DateWrapper.validateRangeInput);
end
[skip, opt] = maybeSkip(pp, varargin{:});
if ~skip
    opt = parse(pp, actual, prediction, varargin{:});
    if any(strcmp(pp.UsingDefaults, 'Range'))
        opt.Range = pp.Results.legacyRange;
    end
end

rmseFunc = @(error, from, to) sqrt(mean(getDataFromTo(error, from, to).^2, 1, 'OmitNaN'));

%--------------------------------------------------------------------------

[from, to] = resolveRange(actual, opt.Range);
error = clip(actual - prediction, from, to);
rmse = rmseFunc(error, from, to);

end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Series/rmseUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set Up Once
    mf = model.File( );
    mf.Code = '!variables x@ !shocks eps !equations x = 0.8*x{-1} + eps;';
    m = Model(mf, 'Linear=', true);
    m = solve(m);
    d = struct( );
    d.eps = Series(1, randn(20, 1));
    d.x = arf(Series(0, 0), [1, -0.8], d.eps, 1:20);
    [~, p] = filter(m, d, 1:20, 'Output=', 'Pred', 'Ahead=', 7, 'MeanOnly=', true);
    d.x = clip(d.x, 1:20);


%% Test Multiple Horizons

   [r0, e0] = rmse(d.x, p.x);
   r1 = sqrt(mean((d.x.Data - p.x.Data).^2, 1, 'OmitNaN'));
   assertEqual(testCase, r0, r1);


%% Test Legacy Range

   [r0, e0] = rmse(d.x, p.x, 2:16);
   r1 = sqrt(mean((d.x.Data(2:16) - p.x.Data(2:16, :)).^2, 1, 'OmitNaN'));
   assertEqual(testCase, r0, r1);


%% Test Range

   [r0, e0] = rmse(d.x, p.x, 'Range=', 3:14);
   r1 = sqrt(mean((d.x.Data(3:14) - p.x.Data(3:14, :)).^2, 1, 'OmitNaN'));
   assertEqual(testCase, r0, r1);

##### SOURCE END #####
%}
