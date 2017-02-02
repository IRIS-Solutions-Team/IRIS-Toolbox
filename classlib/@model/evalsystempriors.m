function [P, C, X] = evalsystempriors(this, s)
% evalsystempriors  Evaluate minus log of system prior density.
%
% Syntax
% =======
%
%     [P,C,X] = evalsystempriors(M,S)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object on which current parameterisation the
% system priors will be evaluated.
%
% * `S` [ systempriors ] - System priors objects.
%
% Output arguments
% =================
%
% * `P` [ numeric ] - Minus log of system prior density.
%
% * `C` [ numeric ] - Contributions of individual prios to the overall
% system prior density.
%
% * `X` [ numeric ] - Value of each expression defining a system property
% for which a prior has been defined in the system priors object, `S`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

[ny, nxx, ~, ~, ne] = sizeOfSolution(this.Vector);
nAlt = length(this);
ns = length(s);

P = nan(1, nAlt);
C = nan(1, ns, nAlt);
X = nan(1, ns, nAlt);

for iAlt = 1 : nAlt
    % Current state space matrices.
    T = this.solution{1}(:, :, iAlt);
    R = this.solution{2}(:, 1:ne, iAlt);
    Z = this.solution{4}(:, :, iAlt);
    H = this.solution{5}(:, :, iAlt);
    U = this.solution{7}(:, :, iAlt);
    Omg = omega(this, [ ], iAlt);
    eig_ = this.Variant{iAlt}.Eigen;
    
    % Shock response function.
    SRF = [ ];
    if ~isempty(s, 'srf')
        nPer = max(s.SystemFn.srf.page);
        shkSize = s.ShkSize;
        SRF = nan(ny+nxx, ne, nPer);
        ixActive = s.SystemFn.srf.activeInput;
        Phi = timedom.srf(T, R(:, ixActive), [ ], Z, H(:, ixActive), [ ], U, [ ], ...
            nPer, shkSize(ixActive));
        SRF(:, ixActive, :) = Phi(:, :, 2:end);
    end
    
    % Number of unit roots.
    nUnit = sum(this.Variant{1}.Stability==TYPE(1));

    % Frequency response function.
    FFRF = [ ];
    if ~isempty(s, 'ffrf')
        freq = s.SystemFn.ffrf.page;
        incl = Inf;
        FFRF = freqdom.ffrf3(T,R,[ ],Z,H,[ ],U,Omg, nUnit,freq, incl,[ ],[ ]);
    end
    
    % Covariance function.
    COV = [ ];
    if ~isempty(s, 'cov') || ~isempty(s, 'corr') || ~isempty(s, 'spd')
        order = max(s.SystemFn.cov.page);
        COV = covfun.acovf(T,R,[ ],Z,H,[ ],U,Omg,eig_,order);
    end
    
    % Correlation function.
    CORR = [ ];
    if ~isempty(s, 'corr')
        CORR = covfun.cov2corr(COV);
    end
    
    % Power spectrum function.
    PWS = [ ];
    if ~isempty(s, 'pws') || ~isempty(s, 'spd')
        freq = s.SystemFn.pws.page;
        PWS = freqdom.xsf(T, R, [ ], Z, H, [ ], U, Omg, nUnit, freq);
    end
    
    % Spectral density function.
    SPD = [ ];
    if ~isempty(s, 'spd')
        SPD = freqdom.psf2sdf(PWS, COV(:, :, 1));
    end
    
    % Evaluate prior log densities.
    x = nan(1, ns);
    c = nan(1, ns);
    p = 0;
    for is = 1 : ns
        x(is) = s.Eval{is}(SRF, FFRF, COV, CORR, PWS, SPD, ...
            this.Variant{1}.Quantity, this.Variant{1}.StdCorr);
        if x(is)<s.LowerBnd(is) || x(is)>s.UpperBnd(is)
            c(is) = Inf;
        elseif ~isempty(s.PriorFn{is})
            c(is) = s.PriorFn{is}(x(is));
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
