function this = createD2S(this, opt)

numQuantities = numel(this.Quantity);
inxY = this.Quantity.Type==1;
inxX = this.Quantity.Type==2;
inxP = this.Quantity.Type==4;
inxG = this.Quantity.Type==5;
inxE = this.Quantity.Type==31 | this.Quantity.Type==32;

inxM = this.Equation.Type==1;
inxT = this.Equation.Type==2;

posY = find(inxY);
posX = find(inxX);
posE = find(inxE);
posP = find(inxP);
posG = find(inxG);

numY = sum(inxY);
numX = sum(inxX);
numE = sum(inxE);
numYXE = numY + numX + numE;
sh0 = this.Incidence.Dynamic.PosZeroShift;


% Look up the actual maximum lead. The maximum lead determines
% whether this is a fwl or bwl model, and how to treat static variables.

[~, modelMaxSh] = getActualMinMaxShifts(this);


% Find max lag `minSh`, and max lead, `maxSh`, for each transition
% variable
[minSh, maxSh] = findMinMaxShift( );
maxMaxSh = max(maxSh(~isnan(maxSh)));
minMinSh = min(minSh(~isnan(minSh)));

% System IDs. These will be used to construct solution IDs.
this.Vector.System{1} = posY;
this.Vector.System{2} = zeros(1, 0);
this.Vector.System{3} = posE;
this.Vector.System{4} = posP;
this.Vector.System{5} = posG;
for k = maxMaxSh : -1 : minMinSh
    % Add all transition variables with shift k.
    this.Vector.System{2} = [ ...
        this.Vector.System{2}, ...
        find(k>=minSh & k<maxSh) + 1i*k ...
    ];
end

numX = numel(this.Vector.System{2});
nu = sum(imag(this.Vector.System{2})>=0);
np = numX - nu;

this.D2S = model.D2S( );

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
this.D2S.DerivY = (sh0-1)*numYXE + posY;
this.D2S.SystemY = 1 : numY;

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
        this.D2S.DerivXf(end+1) = (imag(id)+sh0-1)*numYXE + real(id);
        this.D2S.SystemXf(end+1) = i;
    end
    this.D2S.DerivXfMinus(end+1) = (imag(id)+sh0+1-1)*numYXE + real(id);
    this.D2S.SystemXfMinus(end+1) = i;
end

% Backward variables
for i = 1 : np
    id = this.Vector.System{2}(nu+i);
    if imag(id)==minSh(real(id))
        this.D2S.DerivXb(end+1) = (imag(id)+sh0-1)*numYXE + real(id);
        this.D2S.SystemXb(end+1) = nu + i;
    end
    this.D2S.DerivXbMinus(end+1) = (imag(id)+sh0+1-1)*numYXE + real(id);
    this.D2S.SystemXbMinus(end+1) = nu + i;
end

% __Shocks__
this.D2S.DerivE = (sh0-1)*numYXE + posE;
this.D2S.SystemE = 1 : numE;

% __Dynamic Identity Matrices__
% this.D2S.IdentityA = zeros(0, numX);
% this.D2S.IdentityB = zeros(0, numX);

id__ = this.Vector.System{2};
realId__ = real(id__);
imagId__ = imag(id__);
inxRows = false(1, numX);
for i = 1 : numX
    inxRows(i) = imagId__(i)~=minSh(realId__(i));
end
numRows = nnz(inxRows);
identityA = sparse(numRows, numX);
identityB = sparse(numRows, numX);

row = 0;
for i = find(inxRows)
    row = row + 1;
    identityA(row, this.Vector.System{2}==id__(i)-1i) = 1;
    identityB(row, i) = -1;
end
this.D2S.IdentityA = identityA;
this.D2S.IdentityB = identityB;


% __Solution IDs__

% Number of fwl variables in the unsolved system; may differ from the
% number of fwl variables in the solved system
kf = sum( imag(this.Vector.System{2})>=0 ); 

this.Vector.Solution = this.Vector.System;
this.Vector.Solution{2} = [ ...
    this.Vector.System{2}(~this.D2S.IndexOfXfToRemove), ...
    this.Vector.System{2}(kf+1:end) + 1i ...
];

return


    function [minSh, maxSh] = findMinMaxShift( )
        minSh = nan(1, numQuantities);
        maxSh = nan(1, numQuantities);

        % List of variables requested by user to be in backward-looking vector
        if isequal(opt.makebkw, @auto)
            % Static variables are made forward looking
            inxMakeBkw = false(1, numQuantities);
        elseif isequal(opt.makebkw, @all)
            % Static variables are made backward looking; if all variables
            % are backward looking, the Schur decompositions
            inxMakeBkw = false(1, numQuantities);
            inxMakeBkw(inxX) = true;
        else
            listToMakeBkw = opt.makebkw;
            if ischar(listToMakeBkw)
                listToMakeBkw = regexp(listToMakeBkw, '\w+', 'match');
            end
            [~, inxMakeBkw] = userSelection2Index(this.Quantity, listToMakeBkw);
        end

        % Add transition variables earmarked for measurement to the list of
        % variables forced into the backward lookig vector.
        inxMakeBkw = inxMakeBkw | this.Quantity.InxObserved;

        % Reshape incidence matrix to nEqn-nxx-nsh.
        inc = this.Incidence.Dynamic.Matrix;
        nsh = size(inc, 2) / numQuantities;
        inc = reshape(full(inc), [size(inc, 1), numQuantities, nsh]);

        isAnyNonlin = any(this.Equation.InxHashEquations);
        for ii = posX
            posInc = find( any(inc(inxT, ii, :), 1) ) - sh0;
            posInc = posInc(:).';

            % __Minimum and Maximum Shifts__
            minSh(ii) = min([0, posInc]);
            maxSh(ii) = max([0, posInc]);
            %{
            % User requests adding one lead to all fwl variables
            if opt.addlead && maxSh(ii)>0
                maxSh(ii) = maxSh(ii) + 1;
            end
            %}
            
            % __Leads in Nonlinear Equations__
            % Add one lead to fwl variables in hash signed equations if the max lead of
            % that variable occurs in one of those equations.
            if isAnyNonlin && maxSh(ii)>0
                ixh = inxT & this.Equation.InxHashEquations;
                % Maximum shift referred to in hash signed equations.
                maxOccur = max(find(any(inc(ixh, ii, :), 1)) - sh0);
                if maxOccur==maxSh(ii)
                    maxSh(ii) = maxSh(ii) + 1;
                end
            end
            
            % __Lags in Measurement Variables__
            % If `x(t-k)` occurs in measurement equations then add k-1 lag.
            posInc = find(any(inc(inxM, ii, :), 1)) - sh0;
            posInc = posInc(:).';
            if ~isempty(posInc)
                minSh(ii) = min( minSh(ii), min(posInc)-1 );
            end
            
            % __Request for Backward-Looking Variable__
            % If user requested this variable to be in the backward-looking vector, 
            % make sure `minSh(i)` is at least -1.
            if inxMakeBkw(ii) && minSh(ii)==0
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

