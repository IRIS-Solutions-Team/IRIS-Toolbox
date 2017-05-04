function this = myd2s(this, opt)
% myd2s  Create derivative-to-system convertor.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

nQty = length(this.Quantity);
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
t0 = zero(this.Incidence.Dynamic);

% Find max lag `minSh`, and max lead, `maxSh`, for each transition
% variable.
[minSh, maxSh] = findMinMaxShift( );
maxMaxSh = max(maxSh, [ ], 'OmitNan');
minMinSh = min(minSh, [ ], 'OmitNan');

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

this.d2s = struct( );

% Pre-allocate vectors of positions in derivative matrices
%----------------------------------------------------------
this.d2s.y_ = zeros(1, 0);
this.d2s.xu1_ = zeros(1, 0);
this.d2s.xu_ = zeros(1, 0);
this.d2s.xp1_ = zeros(1, 0);
this.d2s.xp_ = zeros(1, 0);
this.d2s.e_ = zeros(1, 0);

% Pre-allocate vectors of positions in unsolved system matrices
%---------------------------------------------------------------
this.d2s.y = zeros(1, 0);
this.d2s.xu1 = zeros(1, 0);
this.d2s.xu = zeros(1, 0);
this.d2s.xp1 = zeros(1, 0);
this.d2s.xp = zeros(1, 0);
this.d2s.e = zeros(1, 0);

% Transition variables
%----------------------
this.d2s.y_ = (t0-1)*n + posy;
this.d2s.y = 1 : ny;

% Delete double occurences. These emerge whenever a variable has maxshift >
% 0 and minshift<0.
this.d2s.remove = false(1,nu);
for i = 1 : nu
    this.d2s.remove(i) = ...
        any(this.Vector.System{2}(i)-1i==this.Vector.System{2}(nu+1:end)) ...
        || (opt.removeleads && imag(this.Vector.System{2}(i))>0);
end

% Unpredetermined variables
%---------------------------
for i = 1 : nu
    id = this.Vector.System{2}(i);
    if imag(id)==minSh(real(id))
        this.d2s.xu_(end+1) = (imag(id)+t0-1)*n + real(id);
        this.d2s.xu(end+1) = i;
    end
    this.d2s.xu1_(end+1) = (imag(id)+t0+1-1)*n + real(id);
    this.d2s.xu1(end+1) = i;
end

% Predetermined variables
%-------------------------
for i = 1 : np
    id = this.Vector.System{2}(nu+i);
    if imag(id)==minSh(real(id))
        this.d2s.xp_(end+1) = (imag(id)+t0-1)*n + real(id);
        this.d2s.xp(end+1) = nu + i;
    end
    this.d2s.xp1_(end+1) = (imag(id)+t0+1-1)*n + real(id);
    this.d2s.xp1(end+1) = nu + i;
end

% Shocks
%--------
this.d2s.e_ = (t0-1)*n + pose;
this.d2s.e = 1 : ne;

% Dynamic identity matrices
%---------------------------
this.d2s.ident1 = zeros(0, nx);
this.d2s.ident = zeros(0, nx);
for i = 1 : nx
    id = this.Vector.System{2}(i);
    if imag(id) ~= minSh(real(id))
        aux = zeros(1, nx);
        aux(this.Vector.System{2}==id-1i) = 1;
        this.d2s.ident1(end+1,1:end) = aux;
        aux = zeros(1, nx);
        aux(i) = -1;
        this.d2s.ident(end+1,1:end) = aux;
    end
end

% Solution IDs
%--------------
kf = sum( imag(this.Vector.System{2})>=0 ); % Fwl in system.

this.Vector.Solution = this.Vector.System;
this.Vector.Solution{2} = [ ...
    this.Vector.System{2}(~this.d2s.remove), ...
    this.Vector.System{2}(kf+1:end) + 1i ...
    ];

return



    function [minSh, maxSh] = findMinMaxShift( )
        minSh = nan(1, nQty);
        maxSh = nan(1, nQty);
        % List of variables requested by user to be in backward-looking vector.
        if isequal(opt.makebkw, @auto)
            ixMakeBkw = false(1, nQty);
        elseif isequal(opt.makebkw, @all)
            ixMakeBkw = false(1, nQty);
            ixMakeBkw(ixx) = true;
        else
            lsMakeBkw = opt.makebkw;
            if ischar(lsMakeBkw)
                lsMakeBkw = regexp(lsMakeBkw, '\w+', 'match');
            end
            [~, ixMakeBkw] = userSelection2Index(this.Quantity, lsMakeBkw);
        end
        
        % Reshape incidence matrix to nEqn-nxx-nsh.
        inc = this.Incidence.Dynamic.Matrix;
        nsh = size(inc, 2) / nQty;
        inc = reshape(full(inc), [size(inc, 1), nQty, nsh]);
        
        isAnyNonlin = any(this.Equation.IxHash);
        for ii = posx
            posInc = find( any(inc(ixt, ii, :), 1) ) - t0;
            posInc = posInc(:).';
            % Minimum and maximum shifts
            %----------------------------
            minSh(ii) = min([0, posInc]);
            maxSh(ii) = max([0, posInc]);
            % User requests adding one lead to all fwl variables.
            if opt.addlead && maxSh(ii)>0
                maxSh(ii) = maxSh(ii) + 1;
            end
            
            % Leads in nonlinear equations
            %------------------------------
            % Add one lead to fwl variables in hash signed equations if the max lead of
            % that variable occurs in one of those equations.
            if isAnyNonlin && maxSh(ii)>0
                ixh = ixt & this.Equation.IxHash;
                % Maximum shift referred to in hash signed equations.
                maxOccur = max(find(any(inc(ixh, ii, :),1)) - t0);
                if maxOccur==maxSh(ii)
                    maxSh(ii) = maxSh(ii) + 1;
                end
            end
            
            % Lags in measurement variables
            %-------------------------------
            % If `x(t-k)` occurs in measurement equations then add k-1 lag.
            posInc = find(any(inc(ixm, ii, :), 1)) - t0;
            posInc = posInc(:).';
            if ~isempty(posInc)
                minSh(ii) = min( minSh(ii), min(posInc)-1 );
            end
            
            % Request for backward-looking variable
            %---------------------------------------
            % If user requested this variable to be in the backward-looking vector,
            % make sure `minSh(i)` is at least -1.
            if ixMakeBkw(ii) && minSh(ii)==0
                minSh(ii) = -1;
            end
            
            % Static variable
            %-----------------
            % If `minSh(i)`==`maxSh(i)`==0, add an artificial lead to treat the
            % variable as forward-looking (to reduce state space), and to guarantee
            % that all variables will have `maxShift>minShift`.
            if minSh(ii)==maxSh(ii)
                maxSh(ii) = 1;
            end
        end
    end
end
