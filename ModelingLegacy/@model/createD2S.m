function this = createD2S(this, opt)
% createD2S  Create derivative-to-system convertor.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

numOfQuantities = length(this.Quantity);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixp = this.Quantity.Type==TYPE(4);
ixg = this.Quantity.Type==TYPE(5);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixm = this.Equation.Type==TYPE(1);
ixt = this.Equation.Type==TYPE(2);

posy = find(ixy);
posx = find(ixx);
pose = find(ixe);
posp = find(ixp);
posg = find(ixg);

ny = sum(ixy);
nx = sum(ixx);
ne = sum(ixe);
n = ny + nx + ne;
sh0 = this.Incidence.Dynamic.PosOfZeroShift;

% Find max lag `minSh`, and max lead, `maxSh`, for each transition
% variable.
[minSh, maxSh] = findMinMaxShift( );
maxMaxSh = max(maxSh(~isnan(maxSh)));
minMinSh = min(minSh(~isnan(minSh)));

% System IDs. These will be used to construct solution IDs.
this.Vector.System{1} = posy;
this.Vector.System{2} = zeros(1, 0);
this.Vector.System{3} = pose;
this.Vector.System{4} = posp;
this.Vector.System{5} = posg;
for k = maxMaxSh : -1 : minMinSh
    % Add all transition variables with shift k.
    this.Vector.System{2} = [ ...
        this.Vector.System{2}, ...
        find(k>=minSh & k<maxSh) + 1i*k ...
    ];
end

nx = length(this.Vector.System{2});
nu = sum(imag(this.Vector.System{2})>=0);
np = nx - nu;

this.D2S = model.component.D2S( );

% __Preallocate__
% Preallocate vectors of positions in derivative matrices
this.D2S.DerivY = zeros(1, 0);
this.D2S.DerivXfMinus = zeros(1, 0);
this.D2S.DerivXf = zeros(1, 0);
this.D2S.DerivXbMinus = zeros(1, 0);
this.D2S.DerivXb = zeros(1, 0);
this.D2S.DerivE = zeros(1, 0);
% Preallocate vectors of positions in unsolved system matrices
this.D2S.SystemY = zeros(1, 0);
this.D2S.SystemXfMinus = zeros(1, 0);
this.D2S.SystemXf = zeros(1, 0);
this.D2S.SystemXbMinus = zeros(1, 0);
this.D2S.SystemXb = zeros(1, 0);
this.D2S.SystemE = zeros(1, 0);

% __Measurement Variables__
this.D2S.DerivY = (sh0-1)*n + posy;
this.D2S.SystemY = 1 : ny;

% __Transition Variables__
% Delete double occurences. These emerge whenever a variable has maxshift >
% 0 and minshift<0.
this.D2S.IndexOfXfToRemove = false(1, nu);
for i = 1 : nu
    this.D2S.IndexOfXfToRemove(i) = ...
        any(this.Vector.System{2}(i)-1i==this.Vector.System{2}(nu+1:end)) ...
        || (opt.removeleads && imag(this.Vector.System{2}(i))>0);
end

% Forward variables
for i = 1 : nu
    id = this.Vector.System{2}(i);
    if imag(id)==minSh(real(id))
        this.D2S.DerivXf(end+1) = (imag(id)+sh0-1)*n + real(id);
        this.D2S.SystemXf(end+1) = i;
    end
    this.D2S.DerivXfMinus(end+1) = (imag(id)+sh0+1-1)*n + real(id);
    this.D2S.SystemXfMinus(end+1) = i;
end

% Backward variables
for i = 1 : np
    id = this.Vector.System{2}(nu+i);
    if imag(id)==minSh(real(id))
        this.D2S.DerivXb(end+1) = (imag(id)+sh0-1)*n + real(id);
        this.D2S.SystemXb(end+1) = nu + i;
    end
    this.D2S.DerivXbMinus(end+1) = (imag(id)+sh0+1-1)*n + real(id);
    this.D2S.SystemXbMinus(end+1) = nu + i;
end

% __Shocks__
this.D2S.DerivE = (sh0-1)*n + pose;
this.D2S.SystemE = 1 : ne;

% __Dynamic Identity Matrices__
this.D2S.IdentityA = zeros(0, nx);
this.D2S.IdentityB = zeros(0, nx);
for i = 1 : nx
    id = this.Vector.System{2}(i);
    if imag(id) ~= minSh(real(id))
        aux = zeros(1, nx);
        aux(this.Vector.System{2}==id-1i) = 1;
        this.D2S.IdentityA(end+1, 1:end) = aux;
        aux = zeros(1, nx);
        aux(i) = -1;
        this.D2S.IdentityB(end+1, 1:end) = aux;
    end
end

% __Solution IDs__
kf = sum( imag(this.Vector.System{2})>=0 ); % Fwl in system.
this.Vector.Solution = this.Vector.System;
this.Vector.Solution{2} = [ ...
    this.Vector.System{2}(~this.D2S.IndexOfXfToRemove), ...
    this.Vector.System{2}(kf+1:end) + 1i ...
];

return


    function [minSh, maxSh] = findMinMaxShift( )
        minSh = nan(1, numOfQuantities);
        maxSh = nan(1, numOfQuantities);
        % List of variables requested by user to be in backward-looking vector.
        if isequal(opt.makebkw, @auto)
            ixMakeBkw = false(1, numOfQuantities);
        elseif isequal(opt.makebkw, @all)
            ixMakeBkw = false(1, numOfQuantities);
            ixMakeBkw(ixx) = true;
        else
            lsMakeBkw = opt.makebkw;
            if ischar(lsMakeBkw)
                lsMakeBkw = regexp(lsMakeBkw, '\w+', 'match');
            end
            [~, ixMakeBkw] = userSelection2Index(this.Quantity, lsMakeBkw);
        end

        % Add transition variables earmarked for measurement to the list of
        % variables forced into the backward lookig vector.
        ixMakeBkw = ixMakeBkw | this.Quantity.IxObserved;
        
        % Reshape incidence matrix to nEqn-nxx-nsh.
        inc = this.Incidence.Dynamic.Matrix;
        nsh = size(inc, 2) / numOfQuantities;
        inc = reshape(full(inc), [size(inc, 1), numOfQuantities, nsh]);
        
        isAnyNonlin = any(this.Equation.IxHash);
        for ii = posx
            posInc = find( any(inc(ixt, ii, :), 1) ) - sh0;
            posInc = posInc(:).';

            % __Minimum and Maximum Shifts__
            minSh(ii) = min([0, posInc]);
            maxSh(ii) = max([0, posInc]);
            % User requests adding one lead to all fwl variables.
            if opt.addlead && maxSh(ii)>0
                maxSh(ii) = maxSh(ii) + 1;
            end
            
            % __Leads in Nonlinear Equations__
            % Add one lead to fwl variables in hash signed equations if the max lead of
            % that variable occurs in one of those equations.
            if isAnyNonlin && maxSh(ii)>0
                ixh = ixt & this.Equation.IxHash;
                % Maximum shift referred to in hash signed equations.
                maxOccur = max(find(any(inc(ixh, ii, :), 1)) - sh0);
                if maxOccur==maxSh(ii)
                    maxSh(ii) = maxSh(ii) + 1;
                end
            end
            
            % __Lags in Measurement Variables__
            % If `x(t-k)` occurs in measurement equations then add k-1 lag.
            posInc = find(any(inc(ixm, ii, :), 1)) - sh0;
            posInc = posInc(:).';
            if ~isempty(posInc)
                minSh(ii) = min( minSh(ii), min(posInc)-1 );
            end
            
            % __Request for Backward-Looking Variable__
            % If user requested this variable to be in the backward-looking vector, 
            % make sure `minSh(i)` is at least -1.
            if ixMakeBkw(ii) && minSh(ii)==0
                minSh(ii) = -1;
            end
            
            % __Static Variable__
            % If `minSh(i)`==`maxSh(i)`==0, add an artificial lead to treat the
            % variable as forward-looking (to reduce state space), and to guarantee
            % that all variables will have `maxShift>minShift`.
            if minSh(ii)==maxSh(ii)
                maxSh(ii) = 1;
            end
        end
    end
end
