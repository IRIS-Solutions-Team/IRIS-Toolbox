% clpf  Constrained low-pass filter
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [lowp, highp] = clpf(data, lambda, order, infoSet, levelData, changeData, gamma, drift) 

sizeData = size(data);
data = data(:, :);
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

isLevel = ~isempty(levelData);
isChange = ~isempty(changeData);

levelDataSoft = [ ];
levelWeight = [ ];
changeDataSoft = [ ];
changeWeight = [ ];
hereSeparateSoftHard( );

numLambdas = numel(lambda);
numDrifts = size(drift, 2);
numColumns = size(data, 2);
numGammas = size(gamma, 2);
if isLevel
    numLevels = size(levelData, 2);
else
    numLevels = [ ];
end
if isChange
    numChanges = size(changeData, 2);
else
    numChanges = [ ];
end
numRuns = max([numLambdas, numDrifts, numColumns, numLevels, numChanges, numGammas]);

lowp = nan(numPeriods, numRuns);
highp = nan(numPeriods, numRuns);


% /////////////////////////////////////////////////////////////////////////
for run = 1 : numRuns
    if infoSet==2
        % Two-sided filter
        T = numPeriods;
        [XX, xi] = hereDoOneColumn( );
        lowp(:, run) = XX(1:numPeriods);
        highp(:, run) = xi - lowp(:, run);
    else
        % One-sided filter
        for T = 1 : numPeriods
            [XX, xi] = hereDoOneColumn( );
            lowp(T, run) = XX(T);
            highp(T, run) = xi(T) - lowp(T, run);
        end
    end
end
% /////////////////////////////////////////////////////////////////////////


lowp = reshape(lowp, [numPeriods, sizeData(2:end)]);
highp = reshape(highp, [numPeriods, sizeData(2:end)]);

return

    function hereSeparateSoftHard( )
        % Separate soft and hard level tunes.
        if isLevel
            levelData = levelData(:, :);
            remove = isinf(imag(levelData)) | isnan(imag(levelData));
            levelData(remove) = NaN;
            levelDataSoft = nan(size(levelData));
            levelWeight = nan(size(levelData));
            inxSoft = imag(levelData) ~= 0 & ~isnan(real(levelData));
            levelDataSoft(inxSoft) = real(levelData(inxSoft));
            levelWeight(inxSoft) = imag(levelData(inxSoft));
            levelWeight = 1./levelWeight;
            levelData(inxSoft) = NaN;
        end
        % Separate soft and hard growth tunes.
        if isChange
            changeData = changeData(:, :);
            remove = isinf(imag(changeData)) | isnan(imag(changeData));
            changeData(remove) = NaN;
            changeDataSoft = nan(size(changeData));
            changeWeight = nan(size(changeData));
            inxSoft = imag(changeData) ~= 0 & ~isnan(real(changeData));
            changeDataSoft(inxSoft) = real(changeData(inxSoft));
            changeWeight(inxSoft) = imag(changeData(inxSoft));
            changeWeight = 1./changeWeight;
            changeData(inxSoft) = NaN;
        end
    end%


    function [XX, xi] = hereDoOneColumn( )
        xi = data(1:T, min(run, end));
        lambdai = lambda(min(run, end));
        drifti = drift(min(run, end));
        gammai = gamma(1:T, min(run, end));
        
        % Get current level constraints.
        if isLevel
            li = levelData(1:T, min(run, end));
            lsofti = levelDataSoft(1:T, min(run, end));
            lweighti = levelWeight(1:T, min(run, end));
        end
        
        % Get current growth constraints.
        if isChange
            gi = changeData(1:T, min(run, end));
            gsofti = changeDataSoft(1:T, min(run, end));
            gweighti = changeWeight(1:T, min(run, end));
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
        if isChange && any(~isnan(gsofti))
            [X, B] = hereAddGrowthSoft(X, B, gsofti, gweighti);
        end
        
        % Hard level tunes.
        if isLevel && any(~isnan(li))
            [X, B] = hereAddLevel(X, B, li);
        end
        
        % Hard growth tunes.
        if isChange && any(~isnan(gi))
            [X, B] = hereAddGrowth(X, B, gi);
        end
        
        % Filter the data and discard the lagrange multipliers.
        XX = B \ X;
    end%
end%


function [y, b] = hereAddLevel(y, b, levelData)
    levelData = reshape(levelData, [ ], 1);
    index = ~isnan(levelData).';
    if any(index)
        y = [y;levelData(index)];
        for j = find(index)
            b(end+1, j) = 1; %#ok<*AGROW>
            b(j, end+1) = 1;
        end
    end
end% 


function [y, b] = hereAddGrowth(y, b, changeData)
    changeData = reshape(changeData, [ ], 1);
    inx = ~isnan(changeData).';
    if any(inx)
        y = [y;changeData(inx)];
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
    for ii = 2 : n
        x = sum([x(1:end-1);x(2:end)], 1);
        x = [1, x, 1];
    end
    % Row x row.
    x2 = x;
    for ii = 2 : n+1
        x2(ii, ii:end+1) = x(ii)*x;
    end
end%


function b = hereAddGamma(b, gamma, nanObs)
    % xxaddgamma  Add gamma weighted terms to the system (default weight is 1).
    n = size(b, 1);
    e = spdiags(gamma, 0, n, n);
    e(nanObs, nanObs) = 0;
    b = b + e;
end%

