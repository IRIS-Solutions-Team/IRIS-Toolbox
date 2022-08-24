% Type `web Series/rmse.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function [rmse, error] = rmse(actual, prediction, opt)

arguments
    actual Series
    prediction Series

    opt.Range (1, :) double {validate.range} = Inf
end
%}
% >=R2019b


% <=R2019a
%(
function [rmse, error] = rmse(actual, prediction, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "Range", Inf);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


[from, to] = resolveRange(actual, opt.Range);
error = clip(actual - prediction, from, to);
rmse = sqrt(mean(getDataFromTo(error, from, to).^2, 1, 'omitNaN'));

end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Series/rmseUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set Up Once
    mf = ModelSource( );
    mf.Code = '!variables x@ !shocks eps !equations x = 0.8*x{-1} + eps;';
    m = Model(mf, 'Linear', true);
    m = solve(m);
    d = struct( );
    d.eps = Series(1, randn(20, 1));
    d.x = arf(Series(0, 0), [1, -0.8], d.eps, 1:20);
    [~, p] = filter(m, d, 1:20, 'Output', 'Pred', 'Ahead', 7, 'MeanOnly', true);
    d.x = clip(d.x, 1:20);
    p.x = clip(p.x, 1:20);


%% Test Multiple Horizons

   [r0, e0] = rmse(d.x, p.x);
   r1 = sqrt(mean((d.x.Data - p.x.Data).^2, 1, 'OmitNaN'));
   assertEqual(testCase, r0, r1);


%% Test Range

   [r0, e0] = rmse(d.x, p.x, 'Range', 3:14);
   r1 = sqrt(mean((d.x.Data(3:14) - p.x.Data(3:14, :)).^2, 1, 'OmitNaN'));
   assertEqual(testCase, r0, r1);

##### SOURCE END #####
%}

