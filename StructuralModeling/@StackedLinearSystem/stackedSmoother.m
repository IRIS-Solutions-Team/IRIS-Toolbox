function [Xi, Xi0] = stackedSmoother(this, Y, Xi0)

    [T, R, k, Z, H, d] = this.SystemMatrices{1:6};
    [OmegaV, OmegaW] = this.CovarianceMatrices{:};
    [stdV, stdW] = this.StdVectors{:};
    numInit = size(T, 2);

    if ~isempty(stdV)
        Rs = R .* reshape(stdV, 1, [ ]);
        SigmaV = Rs * Rs';
    else
        SigmaV = R*OmegaV*R';
    end
    P = SigmaV;

    if ~isempty(stdW)
        Hs = H .* reshape(stdW, 1, [ ]);
        SigmaW = Hs * Hs';
    elseif ~isempty(OmegaW) && ~isempty(H)
        SigmaW = H*OmegaW*H';
    else
        SigmaW = [ ];
    end

    F = Z * P * Z';
    if ~isempty(SigmaW)
        F = F + SigmaW;
    end
    FiZ = F \ Z;

    %
    % Estimate initial condition if needed
    %
    Xi0 = here_estimateInitialCondition(Xi0);
    TXi0 = T * Xi0;


    %
    % Estimate mean of state vector
    %
    Xi = TXi0 + k;
    U = Y - (Z*Xi + d);
    Xi = Xi + P*(FiZ'*U);


    %
    % Make correction step for exact measurement equations
    %
    Xi = here_makeCorrectionForExactMeasurement(Xi);

return

    function Xi0 = here_estimateInitialCondition(Xi0)
        %(
        if isempty(T)
            Xi0 = zeros(numInit, 1);
            return
        end
        if isempty(Xi0)
            Xi0 = nan(numInit, 1);
        end
        inxXi0 = isfinite(Xi0);
        if all(inxXi0)
            return
        end
        T1 = T(:, inxXi0);
        T2 = T(:, ~inxXi0);
        U0 = Y - (Z*(T1*Xi0(inxXi0, :) + k) + d);
        % Xi0(~inxXi0, :) = (T2'*Z'*(FiZ*T2)) \ (T2'*(FiZ'*U0));
        Xi0(~inxXi0, :) = pinv(T2'*Z'*(FiZ*T2)) * (T2'*(FiZ'*U0));
        %)
    end%


    function Xi = here_makeCorrectionForExactMeasurement(Xi)
        %(
        if isempty(SigmaW)
            Zc = Z;
            Yc = Y;
            dc = d;
        else
            inxExact = diag(SigmaW)==0;
            Zc = Z(inxExact, :);
            Yc = Y(inxExact, :);
            dc = d(inxExact, :);
        end
        U = Yc - (Zc*Xi + dc);
        if any(U(:)~=0)
            Xi = Xi + (((Zc*Zc')\Zc)'*U);
        end
        %)
    end%
end%

