function varargout = xasymptote(This,X0)
% xasymptote  Set or get asymptotic assumptions for exogenous inputs.
%
% Syntax
% =======
%
%     V = xasymptote(V,X0)
%     X = xasymptote(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% * `X0` [ numeric ] - A Nx-NGrp-by-NAlt vector or matrix of asymptotic
% assumptions for exogenous inputs, where Nx is the number of exogenous
% variables, NGrp is the number of groups in panel VARs, and NAlt is the
% number of alternative parameterizations.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object.
%
% Description
% ============
%
% The asymptotic assumptions for exogenous inputs are used in the following
% contexts:
%
% * to compute the asymptotic mean of the VAR process,
% [`mean`](VAR/mean);
%
% * to set up initical conditions for resampling,
% [`resample`](VAR/resample), when they are not supplied in the input
% database.
%
% If any of the three dimensions of the vector/matrix `X0` is size 1, it
% will be automatically expanded to its appropriate size.
%
% The asymptotic assumptions are reset to `NaN` each time the VAR object is
% estimated using the function [`estimate`](VAR/estimate).
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

try
    X0; %#ok<VUNUS>
catch
    varargout{1} = This.X0;
    return
end

%--------------------------------------------------------------------------

nx = length(This.NamesExogenous);
nGrp = max(1,length(This.GroupNames));
nAlt = size(This.A,3);

if size(X0,1) == 1 && nx > 1
    X0 = X0(ones(1,nx),:,:);
end

if size(X0,2) == 1 && nGrp > 1
    X0 = X0(:,ones(1,nGrp),:);
end

if size(X0,3) == 1 && nAlt > 1
    X0 = X0(:,:,ones(1,nAlt));
end

if size(X0,1) ~= nx || size(X0,2) ~= nGrp || size(X0,3) ~= nAlt
    utils.error('VAR:mean', ...
        ['Invalid size of vector/matrix of asymptotic assumptions for ', ...
        'exogenous inputs.']);
end

This.X0 = X0;
varargout{1} = This;

end