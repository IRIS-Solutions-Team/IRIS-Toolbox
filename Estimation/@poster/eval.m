function [obj, L, PP, SP] = eval(this, varargin)
% eval  Evaluate posterior density at specified points.
%
%
% Syntax
% =======
%
%     [X,L,PP,SrfP,FrfP] = eval(Pos)
%     [X,L,PP,SrfP,FrfP] = eval(Pos,P)
%
%
% Input arguments
% ================
%
% * `Pos` [ poster ] - Posterior object returned by the
% [`model/estimate`](model/estimate) function.
%
% * `P` [ struct ] - Struct with parameter values at which the posterior
% density will be evaluated; if `P` is not specified, the posterior density
% is evaluated at the point of the estimated mode.
%
%
% Output arguments
% =================
%
% * `X` [ numeric ] - The value of log posterior density evaluated at `P`;
% N.B. the returned value is log posterior, and not minus log posterior.
%
% * `L` [ numeric ] - Contribution of data likelihood to log posterior.
%
% * `PP` [ numeric ] - Contribution of parameter priors to log posterior.
%
% * `SrfP` [ numeric ] - Contribution of shock response function priors to
% log posterior.
%
% * `FrfP` [ numeric ] - Contribution of frequency response function priors
% to log posterior.
%
%
% Description
% ============
%
% The total log posterior consists, in general, of the four contributions
% listed above:
%
%     X = L + PP + SrfP + FrfP.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if isempty(varargin)
    p = this.InitParam;
elseif length(varargin)==1
    p = varargin{1};
else
    p = varargin;
end

%--------------------------------------------------------------------------

if nargin==1 && nargout<=1
    % Return log posterior at optimum.
    obj = this.InitLogPost;
    return
end

% Evaluate log posterior at specified parameter sets. If
% it's multiple parameter sets, pass them in as a cell, not
% as multiple input arguments.
if isstruct(p)
    p0 = p;
    nPar = numel(this.ParameterNames);
    p = nan(1,nPar);
    for i = 1 : nPar
        p(i) = p0.(this.ParameterNames(i));
    end
end

if ~iscell(p)
    p = { p };
end
np = numel(p);

% Minus log posterior.
obj = nan(size(p));
% Minus log likelihood.
L = nan(size(p));
% Minus log parameter priors.
PP = nan(size(p));
% Minus log system priors.
SP = nan(size(p));

% TODO: parfor
for i = 1 : np
    theta = p{i}(:);
    [obj(i), L(i), PP(i), SP(i)] = mylogpost(this, theta);
end

end%

