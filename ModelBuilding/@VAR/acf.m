function [C,Q] = acf(This,varargin)
% acf  Autocovariance and autocorrelation functions for VAR variables.
%
% Syntax
% =======
%
%     [C,R] = acf(V,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object for which the ACF will be computed.
%
% Output arguments
% =================
%
% * `C` [ namedmat | numeric ] - Auto/cross-covariance matrices.
%
% * `R` [ namedmat | numeric ] - Auto/cross-correlation matrices.
%
% Options
% ========
%
% * `'applyTo='` [ logical | *`@all`* ] - Logical index of variables to
% which the `'filter='` will be applied; `@all` means all variables.
%
% * `'filter='` [ char  | *empty* ] - Linear filter that is applied to
% variables specified by 'applyto'.
%
% * `'MatrixFormat='` [ *`'namedmat'`* | `'plain'` ] - Return matrices `C`
% and `R` as either [`namedmat`](namedmat/Contents) objects (i.e.
% matrices with named rows and columns) or plain numeric arrays.
%
% * `'nFreq='` [ numeric | *`256`* ] - Number of equally spaced frequencies
% over which the `'filter='` is numerically integrated.
%
% * `'order='` [ numeric | *`0`* ] - Order up to which ACF will be
% computed.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the command
% window.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

opt = passvalopt('VAR.acf',varargin{:});

isCorr = nargout > 1;
isNamedMat = strcmpi(opt.MatrixFormat,'namedmat');

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

% Pre-process filter options.
[isFilter,filter,freq,applyTo] ...
    = freqdom.applyfilteropt(opt,[ ],This.YNames);

C = nan(ny,ny,opt.order+1,nAlt);

% Find explosive parameterisations.
ixExpl = isexplosive(This);

if opt.progress
    pBar = ProgressBar('IRIS VAR.acf progress');
end

for iAlt = find(~ixExpl)
    [T,R,~,~,~,~,U,Cov] = sspace(This,iAlt);
    if isFilter
        S = freqdom.xsfvar(This.A(:,:,iAlt),Cov,freq,filter,applyTo);
        C(:,:,:,iAlt) = freqdom.xsf2acf(S,freq,opt.order);
    else
        % Compute contemporaneous ACF for its first-order state space form.
        % This gives us autocovariances up to order p-1.
        c = covfun.acovf(T,R,[ ],[ ],[ ],[ ],U,Cov,This.EigVal(1,:,iAlt),0);
        if p > 1
            c0 = c;
            c = reshape(c0(1:ny,:),ny,ny,p);
        end
        if p == 0
            c(:,:,end+1:opt.order+1) = 0;
        elseif opt.order > p - 1
            % Compute higher-order acfs using Yule-Walker equations.
            c = xxAcovYW(This.A(:,:,iAlt),c,opt.order);
        else
            c = c(:,:,1:1+opt.order);
        end
        C(:,:,:,iAlt) = c;
    end
    % Update the progress bar.
    if opt.progress
        update(pBar,iAlt/sum(~ixExpl));
    end
end

if any(ixExpl)
    % Report explosive parameterisations.
    utils.warning('VAR', ...
        'Cannot compute ACF for explosive parameterisations %s.', ...
        exception.Base.alt2str(ixExpl) );
end

% Fix entries with negative variances.
C = timedom.fixcov(C);

% Autocorrelation function.
if isCorr
    % Convert covariances to correlations.
    Q = covfun.cov2corr(C);
end

if true % ##### MOSW
    % Convert double arrays to namedmat objects if requested.
    if isNamedMat
        C = namedmat(C,This.YNames,This.YNames);
        try %#ok<TRYNC>
            Q = namedmat(Q,This.YNames,This.YNames);
        end
    end
else
    % Do nothing.
end

end


% Subfunctions...


%**************************************************************************


function C = xxAcovYW(A,C,P)

[ny,pNy] = size(A);
p = pNy/ny;

% Residuals included or not in ACF.
ne = size(C,1) - ny;

A = reshape(A(:,1:ny*p),ny,ny,p);
C = C(:,:,1+(0:p-1));
for i = p : P
    X = zeros(ny,ny+ne);
    for j = 1 : size(A,3)
        X = X + A(:,:,j)*C(1:ny,:,end-j+1);
    end
    C(1:ny,:,1+i) = X;
end

end % xxAcovYW( )
