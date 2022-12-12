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

function [meanY, initY] = mean(this, variantsRequested)

    if nargin>=2
        numVariantsRequested = 1;
        variantsRequested = variantsRequested(1);
    else
        numVariantsRequested = countVariants(this);
        variantsRequested = 1 : numVariantsRequested;
    end

    isYInit = nargout>1;

    %--------------------------------------------------------------------------

    numY = size(this.A, 1);
    numX = numel(this.ExogenousNames);
    p = this.Order;
    numGroups = max(1, this.NumGroups);

    % Add the effect of exogenous inputs to the constant term, this.K. this
    % will work also in `sspace(...)`.
    if numX>0
        KJ = this.K(:, :, variantsRequested);
        X0 = this.X0(:, :, variantsRequested);
        here_getExogenousMean();
        this.K(:, :, variantsRequested) = KJ;
    end

    if p==0
        meanY = this.K;
        if isYInit
            initY = zeros(numY, 0, numVariantsRequested);
        end
        return
    end

    realSmall = getrealsmall();

    meanY = nan(numY, 1, 0);
    if isYInit
        initY = nan(numY, p, 0);
    end
    for v = variantsRequested
        [meanY__, initY__] = here_getMean(v);
        meanY = cat(3, meanY, meanY__);
        if isYInit
            initY = cat(3, initY, initY__);
        end
    end

return


    function [m, init] = here_getMean(v)
        unit = abs(abs(this.EigVal(1, :, v)) - 1)<=realSmall;
        nUnit = sum(unit);
        init = [];
        if nUnit==0
            % Stationary parameterisation
            %-----------------------------
            m = sum(polyn.var2polyn(this.A(:,:,v)),3) ...
                \ this.K(:,:,v);
            if isYInit
                % The function `mean` requests initY only when called on VAR, not panel VAR
                % objects; at this point, the size of `m` is guaranteed to be 1 in 2nd
                % dimension.
                init(:, 1:p) = repmat(m, 1, p);
            end
        else
            % Unit-root parameterisation
            %----------------------------
            [T, ~, k, ~, ~, ~, U] = sspace(this, v);
            a2 = (eye(numY*p-nUnit) - T(nUnit+1:end, nUnit+1:end)) ...
                \ k(nUnit+1:end,:);
            % Return NaNs for unit-root variables.
            dy = any( abs(U(1:numY,unit))>realSmall, 2 ).';
            m = nan(size(this.K,1), size(this.K,2));
            m(~dy, :) = U(~dy,nUnit+1:end)*a2;
            if isYInit
                init = U*[zeros(nUnit,1); a2];
                init = reshape(init, numY, p);
                init(:,:) = init(:, end:-1:1);
            end
        end
    end 




    function here_getExogenousMean( )
        if any(isnan(X0(:)))
            utils.warning('VAR:mean', ...
                ['Cannot compute VAR mean. ', ...
                'Asymptotic mean assumptions for exogenous inputs ', ...
                'contain NaNs.']);
        end
        if all(X0(:)==0)
            return
        end
        if numX>0
            for vv = variantsRequested
                for iiGrp = 1 : numGroups
                    pos = (iiGrp-1)*numX + (1:numX);
                    iiX = X0(:, iiGrp, vv);
                    iiJ = this.J(:, pos, vv);
                    KJ(:, iiGrp, vv) = KJ(:, iiGrp, vv) + iiJ*iiX;
                end
            end
        end
    end
end
