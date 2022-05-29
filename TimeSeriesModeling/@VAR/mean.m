function [meanY, initY] = mean(this)
% mean  Asymptotic mean of VAR process.
%
% Syntax
% =======
%
%     M = mean(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
%
% Output arguments
% =================
%
% * `M` [ numeric ] - Asymptotic mean of the VAR variables.
%
%
% Description
% ============
%
% For plain VAR objects, the output argument `X` is a column vector where
% the k-th number is the asymptotic mean of the k-th variable, or `NaN` if
% the k-th variable is non-stationary (contains a unit root).
%
% In panel VAR objects (with a total of Ng groups) and/or VAR objects with
% multiple alternative parameterisations (with a total of Na
% parameterisations), `X` is an Ny-by-Ng-by-Na matrix in which the column
% `X(:,g,a)` is the asyptotic mean of the VAR variables in the g-th group
% and the a-th parameterisation.
%
% In VAR objects with exogenous inputs, the mean will be
% computed based on the asymptotic assumptions of exogenous inputs assigned
% by the function [`xasymptote`](VAR/xasymptote).
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

isYInit = nargout>1;

%--------------------------------------------------------------------------

ny = size(this.A, 1);
nx = length(this.ExogenousNames);
p = size(this.A, 2) / max(ny, 1);
nAlt = size(this.A, 3);
numGroups = max(1, this.NumGroups);

% Add the effect of exogenous inputs to the constant term, this.K. this
% will work also in `sspace(...)`.
if nx>0
    KJ = this.K;
    X0 = this.X0;
    getExogMean( );
    this.K(:,:,:) = KJ;
end

if p==0
    meanY = this.K;
    if isYInit
        initY = zeros(ny, 0, nAlt);
    end
    return
end

realSmall = getrealsmall( );

meanY = nan(size(this.K));
if isYInit
    initY = nan(ny, p, nAlt);
end
for iAlt = 1 : nAlt
    [iMean, iInit] = getMean(iAlt);
    meanY(:, :, iAlt) = iMean;
    if isYInit
        initY(:, :, iAlt) = iInit;
    end
end

return


    function [m, init] = getMean(iAlt)
        unit = abs(abs(this.EigVal(1, :, iAlt)) - 1)<=realSmall;
        nUnit = sum(unit);
        init = [ ];
        if nUnit==0
            % Stationary parameterisation
            %-----------------------------
            m = sum(polyn.var2polyn(this.A(:,:,iAlt)),3) ...
                \ this.K(:,:,iAlt);
            if isYInit
                % The function `mean` requests initY only when called on VAR, not panel VAR
                % objects; at this point, the size of `m` is guaranteed to be 1 in 2nd
                % dimension.
                init(:, 1:p) = repmat(m, 1, p);
            end
        else
            % Unit-root parameterisation
            %----------------------------
            [T, ~, k, ~, ~, ~, U] = sspace(this, iAlt);
            a2 = (eye(ny*p-nUnit) - T(nUnit+1:end, nUnit+1:end)) ...
                \ k(nUnit+1:end,:);
            % Return NaNs for unit-root variables.
            dy = any( abs(U(1:ny,unit))>realSmall, 2 ).';
            m = nan(size(this.K,1), size(this.K,2));
            m(~dy, :) = U(~dy,nUnit+1:end)*a2;
            if isYInit
                init = U*[zeros(nUnit,1); a2];
                init = reshape(init, ny, p);
                init(:,:) = init(:, end:-1:1);
            end
        end
    end 




    function getExogMean( )
        if any(isnan(X0(:)))
            utils.warning('VAR:mean', ...
                ['Cannot compute VAR mean. ', ...
                'Asymptotic mean assumptions for exogenous inputs ', ...
                'contain NaNs.']);
        end
        if all( X0(:)==0 )
            return
        end
        if nx>0
            for iiAlt = 1 : nAlt
                for iiGrp = 1 : numGroups
                    pos = (iiGrp-1)*nx + (1:nx);
                    iiX = X0(:, iiGrp, iiAlt);                    
                    iiJ = this.J(:, pos, iiAlt);
                    KJ(:, iiGrp, iiAlt) = KJ(:, iiGrp, iiAlt) + iiJ*iiX;
                end
            end
        end
    end
end
