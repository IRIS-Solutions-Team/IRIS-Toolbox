function [X,D,D1] = fmse(This,Time,varargin)
% fmse  Forecast mean square error matrices.
%
% Syntax
% =======
%
%     [F,X] = fmse(V,NPer)
%     [F,X] = fmse(V,Range)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object for which the forecast MSE matrices will be
% computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% * `F` [ namedmat | numeric ] - Forecast MSE matrices.
%
% * `X` [ dbase | tseries ] - Database or tseries with the std deviations
% of individual variables, i.e. the square roots of the corresponding
% diagonal elements of `M`.
%
% Options
% ========
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `F` as
% either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% rows and columns) or a plain numeric array.

%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TEMPLATE_SERIES = Series( );

opt = passvalopt('VAR.fmse',varargin{:});

% Tell whether time is nper or range.
if length(Time) == 1 && round(Time) == Time && Time > 0
    range = 1 : Time;
else
    range = Time(1) : Time(end);
end
nPer = length(range);

isNamedMat = strcmpi(opt.MatrixFmt,'namedmat');

%--------------------------------------------------------------------------

ny = size(This.A,1);
nAlt = size(This.A,3);

% Orthonormalise residuals so that we do not have to multiply the VMA
% representation by Omega.
B = covfun.factorise(This.Omega);

% Get VMA representation.
X = timedom.var2vma(This.A,B,nPer);

% Compute FMSE matrices.
for iAlt = 1 : nAlt
    for t = 1 : nPer
        X(:,:,t,iAlt) = X(:,:,t,iAlt)*transpose(X(:,:,t,iAlt));
    end
end
X = cumsum(X,3);

% Return std devs for individual series.
if nargout > 1
    x = nan(nPer,ny,nAlt);
    for i = 1 : ny
        x(:,i,:) = sqrt(permute(X(i,i,:,:),[3,1,4,2]));
    end
    % ##### Nov 2013 OBSOLETE and scheduled for removal.
    % All VAR output data will be returned as dbase (struct).
    D = struct( );
    for i = 1 : ny
        name = This.YNames{i};
        data = x(:,i,:);
        D.(name) = replace(TEMPLATE_SERIES,data(:,:),range(1));
    end
    if nargout > 2
        % ##### Nov 2013 OBSOLETE and scheduled for removal.
        D1 = D;
        utils.warning('obsolete', ...
            ['Syntax with more than 2 output arguments is obsolete, ', ...
            'and will be removed from IRIS in the future.']);
    end
end

if true % ##### MOSW
    % Convert output matrix to namedmat object if requested.
    if isNamedMat
        X = namedmat(X,This.YNames,This.YNames);
    end
else
    % Do nothing.
end

end
