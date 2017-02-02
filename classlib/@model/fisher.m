function [F, FF, delta, freq, G, step] = fisher(this, nPer, lsPar, varargin)
% fisher  Approximate Fisher information matrix in frequency domain.
%
% Syntax
% =======
%
%     [F,FF,Delta,Freq] = fisher(M,NPer,PList,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Solved model object.
%
% * `NPer` [ numeric ] - Length of the hypothetical range for which the
% Fisher information will be computed.
%
% * `PList` [ cellstr ] - List of parameters with respect to which the
% likelihood function will be differentiated.
%
% Output arguments
% =================
%
% * `F` [ numeric ] - Approximation of the Fisher information matrix.
%
% * `FF` [ numeric ] - Contributions of individual frequencies to the total
% Fisher information matrix.
%
% * `Delta` [ numeric ] - Kronecker delta by which the contributions in
% `Fi` need to be multiplied to sum up to `F`.
%
% * `Freq` [ numeric ] - Vector of frequencies at which the Fisher
% information matrix is evaluated.
%
% Options
% ========
%
% * `'chkSstate='` [ `true` | *`false`* | cell ] - Check steady state in
% each iteration; works only in non-linear models.
%
% * `'deviation='` [ *`true`* | `false` ] - Exclude the steady state effect
% at zero frequency.
%
% * `'exclude='` [ char | cellstr | *empty* ] - List of measurement
% variables that will be excluded from the likelihood function.
%
% * `'percent='` [ `true` | *`false`* ] - Report the overall Fisher matrix
% `F` as Hessian w.r.t. the log of variables; the interpretation for this
% is that the Fisher matrix describes the changes in the log-likelihood
% function in reponse to percent, not absolute, changes in parameters.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'solve='` [ *`true`* | `false` | cellstr ] - Re-compute solution in
% each differentiation step; you can specify a cell array with options for
% the `solve` function.
%
% * `'sstate='` [ `true` | *`false`* | cell ] - Re-compute steady state in
% each differentiation step; if the model is non-linear, you can pass in a
% cell array with opt used in the `sstate` function.
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

% Validate required input arguments.
pp = inputParser( );
pp.addRequired('M', @(x) isa(x,'model'));
pp.addRequired('NPer', @(x) isnumeric(x) && length(x)==1);
pp.addRequired('PList', @(x) iscellstr(x) || ischar(x));
pp.parse(this, nPer, lsPar);

% Read and validate optional input arguments.
opt = passvalopt('model.fisher', varargin{:});

ixy = this.Quantity.Type==TYPE(1);
[ny, ~, ~, nf, ne] = sizeOfSolution(this.Vector);
nAlt = length(this);

% Process the 'exclude' option.
ixExclude = false(ny, 1);
if ~isempty(opt.exclude)
    if ischar(opt.exclude)
        opt.exclude = regexp(opt.exclude,'\w+','match');
    end
    lsMeasurementVar = this.Quantity.Name(ixy);
    for i = 1 : length(opt.exclude)
        ix = strcmp(lsMeasurementVar, opt.exclude{i});
        ixExclude(ix) = true;
    end
end

% Get parameter cellstr list from a char list.
if ischar(lsPar)
    lsPar = regexp(lsPar,'\w+','match');
end

% Initialise steady-state solver and chksstate options.
opt.sstate = prepareSteady(this, 'silent', opt.sstate);
opt.chksstate = prepareChkSteady(this, 'silent', opt.chksstate);
opt.solve = prepareSolve(this, 'silent,fast', opt.solve);

EPSILON = eps( )^opt.epspower;

%--------------------------------------------------------------------------

ny = ny - sum(ixExclude);
if ny==0
    utils.warning('model:fisher', ...
        'No measurement variables included in computing Fisher matrix.');
end

ixYLog = this.Quantity.IxLog(ixy);
ixYLog(ixExclude) = [ ];

ell = lookup(this.Quantity, lsPar, TYPE(4));
posQty = ell.PosName;
posStdCorr = ell.PosStdCorr;

ixAssignNan = isnan(posQty);
ixStdcorrNan = isnan(posStdCorr);
ixValid = ~ixAssignNan | ~ixStdcorrNan;
if any(~ixValid)
    utils.error('model:fisher', ...
        'This is not a valid parameter name: ''%s''.', ...
        lsPar{~ixValid});
end

itr = model.IterateOver( );
itr.Quantity = this.Variant{1}.Quantity;
itr.StdCorr = this.Variant{1}.StdCorr;
itr.PosQty = posQty;
itr.PosStdCorr = posStdCorr;

nPList = length(lsPar);
nFreq = floor(nPer/2) + 1;
freq = 2*pi*(0 : nFreq-1)/nPer;

% Kronecker delta vector.
% Different for even or odd number of periods.
delta = ones(1,nFreq);
if mod(nPer,2)==0
    delta(2:end-1) = 2;
else
    delta(2:end) = 2;
end

FF = nan(nPList, nPList, nFreq, nAlt);
F = nan(nPList, nPList, nAlt);

% Create a command-window progress bar.
if opt.progress
    progress = ProgressBar('IRIS model.fisher progress');
end

throwErr = true;

for iAlt = 1 : nAlt    
    % Fetch the i-th parameterisation.
    m = this(iAlt);
    
    % Minimum necessary state space.
    [T0,R0,Z0,H0,Omg0,nunit0] = getSspace( );
    
    % SGF and inverse SGF at p0.
    [G,Gi] = computeSgfy(T0, R0, Z0, H0, Omg0, nunit0, freq, opt);
    
    % Compute derivatives of SGF and steady state
    % wrt the selected parameters.
    dG = nan(ny,ny,nFreq,nPList);
    if ~opt.deviation
        dy = zeros(ny,nPList);
    end
    % Determine differentiation step.
    p0 = nan(1, nPList);
    p0(~ixAssignNan) = m.Variant{1}.Quantity(1, posQty(~ixAssignNan));
    p0(~ixStdcorrNan) = m.Variant{1}.StdCorr(1, posStdCorr(~ixStdcorrNan));
    step = max([abs(p0);ones(1, nPList)],[ ],1)*EPSILON;
    
    for i = 1 : nPList
        pp = p0;
        pm = p0;
        pp(i) = pp(i) + step(i);
        pm(i) = pm(i) - step(i);
        twoSteps = pp(i) - pm(i);

        isSstate = ~opt.deviation && ~isnan(posQty(i));
        
        % Steady state, state space and SGF at p0(i) + step(i).
        m = update(m, pp, itr, 1, opt, throwErr);
        if isSstate
            yp = getSstate( );
        end
        [Tp,Rp,Zp,Hp,Omgp,nunitp] = getSspace( );
        Gp = computeSgfy(Tp,Rp,Zp,Hp,Omgp,nunitp,freq,opt);
        
        % Steady state,state space and SGF at p0(i) - step(i).
        m = update(m, pm, itr, 1, opt, throwErr);
        if isSstate
            ym = getSstate( );
        end
        [Tm,Rm,Zm,Hm,Omgm,nunitm] = getSspace( );
        Gm = computeSgfy(Tm,Rm,Zm,Hm,Omgm,nunitm,freq,opt);
        
        % Differentiate SGF and steady state.
        dG(:,:,:,i) = (Gp - Gm) / twoSteps;
        if isSstate
            dy(:,i) = real(yp(:) - ym(:)) / twoSteps;
        end
        
        % Reset model parameters to `p0`.
        m.Variant{1}.Quantity(1,posQty(~ixAssignNan)) = p0(1,~ixAssignNan);
        m.Variant{1}.StdCorr(1,posStdCorr(~ixStdcorrNan)) = p0(1,~ixStdcorrNan);
        
        % Update the progress bar.
        if opt.progress
            update(progress,((iAlt-1)*nPList+i)/(nAlt*nPList));
        end
        
    end
    
    % Compute Fisher information matrix.
    % Steady-state-independent part.
    for i = 1 : nPList
        for j = i : nPList
            fi = zeros(1,nFreq);
            for k = 1 : nFreq
                fi(k) = ...
                    trace(real(Gi(:,:,k)*dG(:,:,k,i)*Gi(:,:,k)*dG(:,:,k,j)));
            end
            if ~opt.deviation
                % Add steady-state effect to zero frequency.
                % We don't divide the effect by 2*pi because
                % we skip dividing G by 2*pi, too.
                A = dy(:,i)*dy(:,j)';
                fi(1) = fi(1) + nPer*trace(Gi(:,:,1)*(A + A'));
            end
            FF(i,j,:,iAlt) = fi;
            FF(j,i,:,iAlt) = fi;
            f = delta*fi';
            F(i,j,iAlt) = f;
            F(j,i,iAlt) = f;
        end
    end

    if opt.percent
        P0 = diag(p0);
        F(:,:,iAlt) = P0*F(:,:,iAlt)*P0;
    end
    
end
% End of main loop.

FF = FF / 2;
F = F / 2;

return




    function [T, R, Z, H, Omg, nUnit] = getSspace( )
        T = m.solution{1};
        nUnit = sum(this.Variant{1}.Stability==TYPE(1));
        Z = m.solution{4}(~ixExclude, :);
        T = T(nf+1:end, :);
        % Cut off forward expansion.
        R = m.solution{2}(nf+1:end, 1:ne);
        H = m.solution{5}(~ixExclude, 1:ne);
        Omg = omega(m);
    end 



    
    function y = getSstate( )
        % Get the steady-state levels for the measurement variables.
        y = m.Variant{1}.Quantity(ixy);
        y = real(y);
        % Adjust for the excluded measurement variables.
        y(ixExclude) = [ ];
        % Take log of log variables; `ixYLog` has been already adjusted
        % for the excluded measurement variables.
        y(ixYLog) = log(y(ixYLog));
    end 




end 




function [G, Gi] = computeSgfy(T, R, Z, H, Omg, nUnit, freq, opt)
% Spectrum generating function and its inverse.
% Computationally optimised for observables.
[ny, nb] = size(Z);
nFreq = length(freq(:));
Sgm1 = R*Omg*R.';
Sgm2 = H*Omg*H.';
G = nan(ny,ny,nFreq);
for i = 1 : nFreq
    iFreq = freq(i);
    if iFreq==0 && nUnit>0
        % Exclude the unit-root part of the transition matrix, and compute SGF only
        % for the stable part. Stationary variables are unaffected.
        Z0 = Z(:, nUnit+1:end);
        T0 = T(nUnit+1:end, nUnit+1:end);
        R0 = R(nUnit+1:end, :);
        X = Z0 / (eye(nb-nUnit) - T0);
        G(:,:,i) = trimSymmetric(X*(R0*Omg*R0.')*X' + Sgm2);
    else
        X = Z/(eye(nb) - T*exp(-1i*iFreq));
        G(:,:,i) = trimSymmetric(X*Sgm1*X' + Sgm2);
    end
    
end
% Do not divide G by 2*pi.
% First, this cancels out in Gi*dG*Gi*dG
% and second, we do not divide the steady-state effect
% by 2*pi either.
if nargout>1
    Gi = nan(ny, ny, nFreq);
    if opt.chksgf
        for i = 1 : nFreq
            Gi(:,:,i) = computePseudoInverse(G(:,:,i), opt.tolerance);
        end
    else
        for i = 1 : nFreq
            Gi(:,:,i) = inv(G(:,:,i));
        end
    end
end
end 




function x = trimSymmetric(x)
% Minimise numerical inaccuracy between upper and lower parts
% of symmetric matrices.
index = eye(size(x))==1;
x = (x + x')/2;
x(index) = real(x(index));
end 




function X = computePseudoInverse(A, Tol)
c = class(A);
if isempty(A)
    X = zeros(size(A'),c);
    return
end
m = size(A,1);
s = svd(A);
r = sum(s/s(1)>Tol);
if r==0
    X = zeros(size(A'),c);
elseif r==m
    X = inv(A);
else
    [U, ~, V] = svd(A, 0);
    S = diag(1./s(1:r));
    X = V(:,1:r)*S*U(:,1:r)';
end
end
