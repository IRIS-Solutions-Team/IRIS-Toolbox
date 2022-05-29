function [Y0, K0, X0, Y1, G1, CI] = stackData(this, yInp, xInp, ixGroupSpec, opt) %#ok<INUSL>
% stackData  Stack input data for VAR estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
 
%--------------------------------------------------------------------------

% Plain (non-panel) input data are stored in 1-by-1 cell arrays, as are
% 1-group panel VARs.
ixGroupSpecConst = ixGroupSpec(1);
ixGroupSpecX = ixGroupSpec(2:end);
nGrp = length(yInp);
ny = size(yInp{1}, 1);
kx = size(xInp{1}, 1);
nv = size(yInp{1}, 3);
nXPer = size(yInp{1}, 2); % nXPer is the same for each group because Range cannot be Inf for panel VARs.
order = opt.Order;


% Endogenous variables
%----------------------

Y0 = [ ];
for iGrp = 1 : nGrp
    % Separate groups by a total of order NaNs.
    Y0 = [Y0, yInp{iGrp}, nan(ny, order, nv)]; %#ok<AGROW>
end
n = size(Y0, 2);


% Constant including fixed effect
%---------------------------------
K0 = zeros(0, n);
if opt.Intercept
    if nGrp==1 || ~ixGroupSpecConst
        % Constant term in non-panels or estimated for all groups.
        K0 = ones(1, n);
    else
        % Dummy constants for fixed-effect panel estimation.
        % Separate each group by a total of `order` NaNs so that two adjacent groups do
        % not interfere in estimation.
        K0 = zeros(nGrp, 0);
        for iGrp = 1 : nGrp
            k = zeros(nGrp, nXPer+order);
            k(iGrp, 1:nXPer) = 1;
            k(iGrp, nXPer+1:end) = NaN;
            K0 = [K0, k]; %#ok<AGROW>
        end
    end
end


% Exogenous inputs including fixed effect
%-----------------------------------------
s3 = size(xInp{1}, 3);
X0 = zeros(0, nGrp*(nXPer+order), s3);
if kx>0
    % Total number of rows in X0 depends on how many exogenous variables with
    % group-specific coefficients there are.
    X0 = zeros(0, nGrp*(nXPer+order), s3);
    for i = 1 : kx
        if ixGroupSpecX(i)
            x = zeros(nGrp, 0, s3);
            for iGrp = 1 : nGrp
                z = zeros(nGrp, nXPer+order, s3);
                z(iGrp, :, :) = [xInp{iGrp}(i, :, :), nan(1, order, s3)];
                x = [x, z]; %#ok<AGROW>
            end
        else
            x = zeros(1, 0, s3);
            for iGrp = 1 : nGrp
                x = [x, xInp{iGrp}(i, :, :), nan(1, order, s3)]; %#ok<AGROW>
            end
        end
        X0 = [X0; x]; %#ok<AGROW>
    end
end


% __Cointegrating Vectors and Difference__
% Only one set of cointegrating vectors allowed
CI = opt.Cointeg;
if isempty(CI)
    CI = zeros(0, 1+ny);
else
    if size(CI,2)==ny
        CI = [ones(size(CI,1), 1), CI];
    end
end
ng = size(CI, 1);
G1 = zeros(ng, n, nv);
if ~opt.Diff
    % __Level VAR__
    Y1 = nan(order*ny, n, nv);
    for i = 1 : order
        Y1((i-1)*ny+(1:ny),1+i:end,:) = Y0(:,1:end-i,:);
    end  
else
    % __VEC or Difference VAR__
    dY0 = nan(size(Y0));
    dY0(:,2:end,:) = Y0(:,2:end,:) - Y0(:,1:end-1,:);
    % Current dated and lagged differences of endogenous variables
    % Add the co-integrating vector and differentiate data
    kg = ones(1, n);
    if ~isempty(CI)
        for iLoop = 1 : nv
            y = nan(ny, n);
            y(:,2:end) = Y0(:, 1:end-1, iLoop);
            % Lag of the co-integrating vector.
            G1(:,:,iLoop) = CI*[kg; y];
        end
    end
    dY1 = nan((order-1)*ny, n, nv);
    for i = 1 : order-1
        dY1((i-1)*ny+(1:ny), 1+i:end, :) = dY0(:, 1:end-i, :);
    end
    Y0 = dY0;
    Y1 = dY1;
end

end%

