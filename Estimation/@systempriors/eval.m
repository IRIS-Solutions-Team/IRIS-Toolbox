function [P, C, X] = eval(this, m)
% eval  Evaluate minus log of system prior density.
%
% Syntax
% =======
%
%     [p, c, x] = eval(s, m)
%
%
% Input arguments
% ================
%
% * `s` [ systempriors ] - System priors object.
%
% * `m` [ model ] - Model object on which the system priors will be
% evaluated.
%
%
% Output arguments
% =================
%
% * `p` [ numeric ] - Minus log of system prior density, up to an
% integration constant.
%
% * `c` [ numeric ] - Contributions of individual system priors to the overall
% log density.
%
% * `x` [ numeric ] - Value of each expression defining a system property
% for which a prior has been defined in the system priors object, `s`.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nAlt = length(m);
ns = length(this);

P = nan(1, nAlt);
C = nan(1, ns, nAlt);
X = nan(1, ns, nAlt);

for iAlt = 1 : nAlt
    % Current state space matrices.
    [T, R, ~, Z, H, ~, U, Omg] = sspaceMatrices(m, iAlt, false);
    [eigenVal, stability] = eig(m, iAlt);
    [asgndQty, asgndStdCorr] = assigned(m, iAlt);
    ny = size(Z, 1);
    nxx = size(T, 1);
    ne = size(H, 2);

    % Shock response function.
    SRF = [ ];
    if ~isempty(this, 'srf')
        nPer = max(this.SystemFn.srf.page);
        shkSize = this.ShkSize;
        SRF = nan(ny+nxx, ne, nPer);
        ixActive = this.SystemFn.srf.activeInput;
        Phi = timedom.srf(T, R(:, ixActive), [ ], Z, H(:, ixActive), [ ], U, [ ], ...
            nPer, shkSize(ixActive));
        SRF(:, ixActive, :) = Phi(:, :, 2:end);
    end
    
    % Number of unit roots.
    nUnit = sum(stability==TYPE(1));

    % Frequency response function.
    FFRF = [ ];
    if ~isempty(this, 'ffrf')
        freq = this.SystemFn.ffrf.page;
        incl = Inf;
        FFRF = freqdom.ffrf3(T, R, [ ], Z, H, [ ], U, Omg, nUnit, freq, incl, [ ], [ ]);
    end
    
    % Covariance function.
    COV = [ ];
    if ~isempty(this, 'cov') || ~isempty(this, 'corr') || ~isempty(this, 'spd')
        order = max(this.SystemFn.cov.page);
        COV = covfun.acovf(T, R, [ ], Z, H, [ ], U, Omg, eigenVal, order);
    end
    
    % Correlation function.
    CORR = [ ];
    if ~isempty(this, 'corr')
        CORR = covfun.cov2corr(COV);
    end
    
    % Power spectrum function.
    PWS = [ ];
    if ~isempty(this, 'pws') || ~isempty(this, 'spd')
        freq = this.SystemFn.pws.page;
        PWS = freqdom.xsf(T, R, [ ], Z, H, [ ], U, Omg, nUnit, freq);
    end
    
    % Spectral density function.
    SPD = [ ];
    if ~isempty(this, 'spd')
        SPD = freqdom.psf2sdf(PWS, COV(:, :, 1));
    end
    
    % Evaluate prior log densities and check lower and upper bounds.
    x = nan(1, ns);
    c = nan(1, ns);
    p = 0;
    for is = 1 : ns
        x(is) = this.Eval{is}(SRF, FFRF, COV, CORR, PWS, SPD, asgndQty, asgndStdCorr);
        if x(is)<this.Bounds(1, is) || x(is)>this.Bounds(2, is)
            c(is) = Inf;
        elseif ~isempty(this.PriorFn{is})
            c(is) = this.PriorFn{is}(x(is));
        else
            % Empty prior function handle means uniform distribution.
            c(is) = 0;
        end
        % Minus log density.
        c(is) = -c(is);
        p = p + c(is);
        if ~isfinite(p)
            p = Inf;
            if nargout==1
                break
            end
        end
    end

    P(1, iAlt) = p;
    C(1, :, iAlt) = c;
    X(1, :, iAlt) = x;
end

end
