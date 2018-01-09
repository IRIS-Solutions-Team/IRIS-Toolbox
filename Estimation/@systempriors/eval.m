function [P, C, X] = eval(this, m)
% eval  Evaluate minus log of system prior density.
%
% __Syntax__
%
%     [P, C, X] = eval(S, M)
%
%
% __Input Arguments__
%
% * `S` [ systempriors ] - System priors object.
%
% * `M` [ model ] - Model object on which the system priors will be
% evaluated.
%
%
% __Output Arguments__
%
% * `P` [ numeric ] - Minus log of system prior density, up to an
% integration constant.
%
% * `C` [ numeric ] - Contributions of individual system priors to the overall
% log density.
%
% * `X` [ numeric ] - Value of each expression defining a system property
% for which a prior has been defined in the system priors object, `S`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nv = length(m);
ns = length(this);

P = nan(1, nv);
C = nan(1, ns, nv);
X = nan(1, ns, nv);

for v = 1 : nv
    % Current state space matrices.
    [T, R, ~, Z, H, ~, U, Omg] = sspaceMatrices(m, v, false);
    [~, eigenStability] = eig(m, v);
    indexUnitRoots = eigenStability==TYPE(1);
    numUnitRoots = nnz(indexUnitRoots);
    [assignedValues, assignedStdCorr] = assigned(m, v);
    ny = size(Z, 1);
    nxi = size(T, 1);
    ne = size(H, 2);

    % Shock response function.
    SRF = [ ];
    if ~isempty(this, 'srf')
        numPeriosToSimulate = max(this.SystemFn.srf.page);
        shkSize = this.ShkSize;
        SRF = nan(ny+nxi, ne, numPeriosToSimulate);
        ixActive = this.SystemFn.srf.activeInput;
        Phi = timedom.srf( ...
            T, R(:, ixActive), [ ], Z, H(:, ixActive), [ ], U, [ ], ...
            numPeriosToSimulate, shkSize(ixActive));
        SRF(:, ixActive, :) = Phi(:, :, 2:end);
    end
    
    % Frequency response function.
    FFRF = [ ];
    if ~isempty(this, 'ffrf')
        freq = this.SystemFn.ffrf.page;
        incl = true(1, ny);
        FFRF = freqdom.ffrf3( ...
            T, R, [ ], Z, H, [ ], U, Omg, numUnitRoots, freq, incl, 1e-7, 500 ...
        );
    end
    
    % Covariance function.
    COV = [ ];
    if ~isempty(this, 'cov') || ~isempty(this, 'corr') || ~isempty(this, 'spd')
        order = max(this.SystemFn.cov.page);
        COV = covfun.acovf(T, R, [ ], Z, H, [ ], U, Omg, indexUnitRoots(1:nb), order);
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
        PWS = freqdom.xsf(T, R, [ ], Z, H, [ ], U, Omg, numUnitRoots, freq);
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
        x(is) = this.Eval{is}(SRF, FFRF, COV, CORR, PWS, SPD, assignedValues, assignedStdCorr);
        ithPrior = this.PriorFn{is};
        if x(is)<this.Bounds(1, is) || x(is)>this.Bounds(2, is)
            c(is) = -Inf;
        elseif ~isempty(ithPrior)
            if isa(ithPrior, 'distribution.Abstract')
                c(is) = ithPrior.logPdf(x(is));
            elseif isa(ithPrior, 'function_handle')
                c(is) = ithPrior(x(is));
            end
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

    P(1, v) = p;
    C(1, :, v) = c;
    X(1, :, v) = x;
end

end
