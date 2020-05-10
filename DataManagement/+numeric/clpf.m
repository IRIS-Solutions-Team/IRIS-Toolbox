function [lowp, highp] = clpf(xData, lambda, varargin)
% clpf  Constrained low-pass filter
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

opt = passvalopt('tseries.clpf', varargin{:});
order = opt.Order;
infoSet = opt.InfoSet;
lData = opt.Level;
gData = opt.Change;
gamma = opt.Gamma;
drift = opt.Drift;

%--------------------------------------------------------------------------

sizeData = size(xData);
xData = xData(:, :);
numPeriods = sizeData(1);
lambda = reshape(lambda, 1, [ ]);

gamma = gamma(:, :);
if size(gamma, 1)==1
    gamma = repmat(gamma, numPeriods, 1);
end

drift = drift(:, :);
if size(drift, 1)==1
    drift = repmat(drift, numPeriods, 1);
end

isLevel = ~isempty(lData);
isGrowth = ~isempty(gData);

lDataSoft = [ ];
lWeight = [ ];
gDataSoft = [ ];
gWeight = [ ];
hereSeparateSoftHard( );


nLambda = length(lambda);
nDrift = size(drift, 2);
nx = size(xData, 2);
nGamma = size(gamma, 2);
if isLevel
    nl = size(lData, 2);
else
    nl = [ ];
end
if isGrowth
    ng = size(gData, 2);
else
    ng = [ ];
end
nLoop = max([nLambda, nDrift, nx, nl, ng, nGamma]);

lowp = nan(numPeriods, nLoop);
highp = nan(numPeriods, nLoop);

% Main loop.
for iLoop = 1 : nLoop
    if infoSet==2
        % Two-sided filter.
        T = numPeriods;
        [XX, xi] = hereDoOneColumn( );
        lowp(:, iLoop) = XX(1:numPeriods);
        highp(:, iLoop) = xi - lowp(:, iLoop);
    else
        % One-sided filter.
        for T = 1 : numPeriods
            [XX, xi] = hereDoOneColumn( );
            lowp(T, iLoop) = XX(T);
            highp(T, iLoop) = xi(T) - lowp(T, iLoop);
        end
    end
end

lowp = reshape(lowp, [numPeriods, sizeData(2:end)]);
highp = reshape(highp, [numPeriods, sizeData(2:end)]);

return


    function hereSeparateSoftHard( )
        % Separate soft and hard level tunes.
        if isLevel
            lData = lData(:, :);
            remove = isinf(imag(lData)) | isnan(imag(lData));
            lData(remove) = NaN;
            lDataSoft = nan(size(lData));
            lWeight = nan(size(lData));
            softindex = imag(lData) ~= 0 & ~isnan(real(lData));
            lDataSoft(softindex) = real(lData(softindex));
            lWeight(softindex) = imag(lData(softindex));
            lWeight = 1./lWeight;
            lData(softindex) = NaN;
        end
        % Separate soft and hard growth tunes.
        if isGrowth
            gData = gData(:, :);
            remove = isinf(imag(gData)) | isnan(imag(gData));
            gData(remove) = NaN;
            gDataSoft = nan(size(gData));
            gWeight = nan(size(gData));
            softindex = imag(gData) ~= 0 & ~isnan(real(gData));
            gDataSoft(softindex) = real(gData(softindex));
            gWeight(softindex) = imag(gData(softindex));
            gWeight = 1./gWeight;
            gData(softindex) = NaN;
        end
    end%




    function [XX, xi] = hereDoOneColumn( )
        xi = xData(1:T, min(iLoop, end));
        lambdai = lambda(min(iLoop, end));
        drifti = drift(min(iLoop, end));
        gammai = gamma(1:T, min(iLoop, end));
        
        % Get current level constraints.
        if isLevel
            li = lData(1:T, min(iLoop, end));
            lsofti = lDataSoft(1:T, min(iLoop, end));
            lweighti = lWeight(1:T, min(iLoop, end));
        end
        
        % Get current growth constraints.
        if isGrowth
            gi = gData(1:T, min(iLoop, end));
            gsofti = gDataSoft(1:T, min(iLoop, end));
            gweighti = gWeight(1:T, min(iLoop, end));
        end
        
        % Multiply observations by gamma weights.
        xi = gammai.*xi;
        
        % System matrix for filter with no tunes.
        [X, B] = herePlainSystem(xi, lambdai, gammai, drifti, order);
        
        % Do soft tunes first because we assume that the coefficient matrix is
        % T-by-T in `xxaddlevelsoft` and `xxaddgrowthsoft`. Hard tunes then expand
        % the system matrix in both dimensions.
        
        % Soft level tunes.
        if isLevel && any(~isnan(lsofti))
            [X, B] = hereAddLevelSoft(X, B, lsofti, lweighti);
        end
        
        % Soft growth tunes.
        if isGrowth && any(~isnan(gsofti))
            [X, B] = hereAddGrowthSoft(X, B, gsofti, gweighti);
        end
        
        % Hard level tunes.
        if isLevel && any(~isnan(li))
            [X, B] = hereAddLevel(X, B, li);
        end
        
        % Hard growth tunes.
        if isGrowth && any(~isnan(gi))
            [X, B] = hereAddGrowth(X, B, gi);
        end
        
        % Filter the data and discard the lagrange multipliers.
        XX = B \ X;
    end%
end%




function [y, b] = hereAddLevel(y, b, lData)
    lData = reshape(lData, [ ], 1);
    index = ~isnan(lData).';
    if any(index)
        y = [y;lData(index)];
        for j = find(index)
            b(end+1, j) = 1; %#ok<*AGROW>
            b(j, end+1) = 1;
        end
    end
end% 




function [y, b] = hereAddGrowth(y, b, gData)
    gData = reshape(gData, [ ], 1);
    inx = ~isnan(gData).';
    if any(inx)
        y = [y;gData(inx)];
        for j = find(inx)
            b(end+1, [j-1, j]) = [-1, 1];
            b([j-1, j], end+1) = [-1;1];
        end
    end
end%




function [y, b] = hereAddLevelSoft(y, b, lSoft, lw)
    inx = ~isnan(lSoft);
    inx = reshape(inx, 1, [ ]);
    y(inx) = y(inx) + lw(inx).*lSoft(inx);
    for j = find(inx)
        b(j, j) = b(j, j) + lw(j);
    end
end% 




function [y, b] = hereAddGrowthSoft(y, b, gSoft, gw)
    inx = ~isnan(gSoft);
    inx = reshape(inx, 1, [ ]);
    inx1 = [inx(2:end), false];
    y(inx) = y(inx) + gw(inx).*gSoft(inx);
    y(inx1) = y(inx1) - gw(inx).*gSoft(inx);
    for j = find(inx)
        b(j-1:j, j-1:j) =  b(j-1:j, j-1:j) + gw(j)*[1, -1;-1, 1];
    end
end%




function [y, b] = herePlainSystem(y, lambda, gamma, drift, p)
    numPeriods = size(y, 1);
    if numPeriods <= p
        % Trend is simply observations.
        b = zeros(numPeriods);
    else
        row = herePascalRow(p);
        if rem(p, 2) == 0
            % Coefficient signs for even orders (e.g. HPF).
            sgn = (-1).^(0 : 2*p);
        else
            % Coefficient signs for odd orders (e.g. LLF).
            sgn = (-1).^(1 : 2*p+1);
        end
        row = row .* sgn(ones(1, p+1), :);
        if  numPeriods < 2*p
            b = zeros(numPeriods);
            rng = -p : p;
            repeat = ones(1, size(row, 1));
            for t = 1 : numPeriods
                isAvail = t+rng >= 1 & t+rng <= numPeriods;
                keep = all(row == 0 | isAvail(repeat, :), 2);
                sumRow = sum(row(keep, :), 1);
                b(t, t+rng(isAvail)) = sumRow(isAvail);
            end
            b = b*lambda;
        else
            BDiags = sum(row, 1);
            BDiags = BDiags(ones(1, numPeriods), :);
            cumRow = cumsum(row, 1);
            cumRow(cumRow == 0) = NaN;
            n = min(p, ceil(numPeriods/2));
            cumRow = cumRow(1:n, :);
            BDiags(1:n, 1:2*p+1) = cumRow;
            BDiags(end-p+1:end, end-2*p:end) = cumRow(end:-1:1, end:-1:1);
            BDiags = BDiags*lambda;
            b = spdiags(BDiags, -p:p, numPeriods, numPeriods);
        end
    end
    nanObs = isnan(y);
    y(nanObs) = 0;
    % Add drift (LLF).
    y(1) = y(1) - lambda*drift;
    y(end) = y(end) + lambda*drift;
    % Add time-varying gamma weights or add ones along the main diagonal.
    b = hereAddGamma(b, gamma, nanObs);
end%




function x2 = herePascalRow(n)
    % xxPascalRows  Get decomposition of one row of the Pascal triangle.
    if n == 0
        x2 = 1;
        return
    end
    % Pascal triangle.
    x = [1, 1];
    for i = 2 : n
        x = sum([x(1:end-1);x(2:end)], 1);
        x = [1, x, 1];
    end
    % Row x row.
    x2 = x;
    for i = 2 : n+1
        x2(i, i:end+1) = x(i)*x;
    end
end%




function b = hereAddGamma(b, gamma, nanObs)
    % xxaddgamma  Add gamma weighted terms to the system (default weight is 1).
    n = size(b, 1);
    e = spdiags(gamma, 0, n, n);
    e(nanObs, nanObs) = 0;
    b = b + e;
end%
