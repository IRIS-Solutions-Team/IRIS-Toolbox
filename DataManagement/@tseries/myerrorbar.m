function H = myerrorbar(axesHandle, X, Y, Lo, Hi, opt, varargin)

if isfield(opt, 'excludefromlegend') && ~isfield(opt, 'ExcludeFromLegend')
    opt.ExcludeFromLegend = opt.excludefromlegend;
end

if isfield(opt, 'relative') && ~isfield(opt, 'Relative')
    opt.Relative = opt.relative;
end

if size(X, 1) == 1
    X = transpose(X);
end
[nPer, nx] = size(X);

if size(Y, 1) == 1
    Y = transpose(Y);
end
ny = size(Y, 2);

if size(Lo, 1) == 1
    Lo = transpose(Lo);
end
nLo = size(Lo, 2);

if size(Hi, 1) == 1
    Hi = transpose(Hi);
end
nHi = size(Hi, 2);

n = max(nx, ny);

xData = nan(3*nPer, n);
yData = nan(3*nPer, n);
for i = 1 : n
    if i <= nx
        iX = X(:, i);
    end
    if i <= ny
        iY = Y(:, i);
    end
    if i <= nLo
        iLo = Lo(:, i);
    end
    if i <= nHi
        iHi = Hi(:, i);
    end
    if opt.Relative
        inx = abs(iLo) <= 0 & abs(iHi) <= 0;
        iLo(inx) = NaN;
        iHi(inx) = NaN;
    end
    tempXData = [iX, iX, nan(size(iX))].';
    xData(:, i) = tempXData(:);
    if opt.Relative
        if all(iLo(:) >= 0 | isnan(iLo(:)))
            iLo = -iLo;
        end
        tempYData = [iY+iLo, iY+iHi, nan(size(iY))].';
    else
        tempYData = [iLo, iHi, nan(size(iY))].';
    end
    yData(:, i) = tempYData(:);
end

H = plot(axesHandle, xData, yData);

if ~isempty(varargin)
    set(H, varargin{:});
end
set(H, 'marker', '+', 'linestyle', ':');

if opt.ExcludeFromLegend
    grfun.excludefromlegend(H);
end

end%

