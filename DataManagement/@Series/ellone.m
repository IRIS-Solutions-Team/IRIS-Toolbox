% ellone  L1 norm trend filtering
%{
% ## Syntax ##
%
%
%     output = function(input, ...)
%
%
% ## Input Arguments ##
%
%
% __`input`__ [ | ]
% >
% Description
%
%
% ## Output Arguments ##
%
%
% __`output`__ [ | ]
% >
% Description
%
%
% ## Options ##
%
%
% __`OptionName=Default`__ [ | ]
% >
% Description
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

function [trend, rem] = ellone(this, order, lambda, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('TimeSubscriptable.ellone');
    addRequired(pp, 'inputSeries', @(x) isa(x, 'TimeSubscriptable') && isnumeric(x.Data));
    addRequired(pp, 'order', @(x) isequal(x, 1) || isequal(x, 2));
    addRequired(pp, 'lambda', @(x) isnumeric(x) && isscalar(x) && x>0);

    addParameter(pp, 'Range', Inf, @validate.range);
end
parse(pp, this, order, lambda, varargin{:});
opt = pp.Results;

%--------------------------------------------------------------------------

[data, newStart] = getDataFromTo(this, opt.Range);
numPeriods = size(data, 1);

d = eye(numPeriods-order, numPeriods);
D = d;
if order==1
    D(:, 2:end) = D(:, 2:end) - d(:, 1:end-1);
else
    D(:, 2:end) = D(:, 2:end) - 2*d(:, 1:end-1); 
    D(:, 3:end) = D(:, 3:end) + d(:, 1:end-2);
end

H = D*D';
f = -D*data;
bound = repmat(lambda, numPeriods-order, 1);
nu = quadprog(H, f, [ ], [ ], [ ], [ ], -bound, bound);
trendData = data - D'*nu;

trend = fill(this, trendData, newStart);
rem = fill(this, data - trendData, newStart);

end%

