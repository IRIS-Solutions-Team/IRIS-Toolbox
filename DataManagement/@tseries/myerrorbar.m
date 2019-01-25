function H = myerrorbar(X,Y,Lo,Hi,Opt,varargin)
% myerrorbar  [Not a public function] Add error bars to an existing plot.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

realSmall = 0; %getrealsmall( );

if size(X,1) == 1
    X = transpose(X);
end
[nPer,nx] = size(X);

if size(Y,1) == 1
    Y = transpose(Y);
end
ny = size(Y,2);

if size(Lo,1) == 1
    Lo = transpose(Lo);
end
nLo = size(Lo,2);

if size(Hi,1) == 1
    Hi = transpose(Hi);
end
nHi = size(Hi,2);

n = max(nx,ny);

xData = nan(3*nPer,n);
yData = nan(3*nPer,n);
for i = 1 : n
    if i <= nx
        iX = X(:,i);
    end
    if i <= ny
        iY = Y(:,i);
    end
    if i <= nLo
        iLo = Lo(:,i);
    end
    if i <= nHi
        iHi = Hi(:,i);
    end
    if Opt.relative
        inx = abs(iLo) <= realSmall & abs(iHi) <= realSmall;
        iLo(inx) = NaN;
        iHi(inx) = NaN;
    end
    tempXData = [iX,iX,nan(size(iX))].';
    xData(:,i) = tempXData(:);
    if Opt.relative
        if all(iLo(:) >= 0 | isnan(iLo(:)))
            iLo = -iLo;
        end
        tempYData = [iY+iLo,iY+iHi,nan(size(iY))].';
    else
        tempYData = [iLo,iHi,nan(size(iY))].';
    end
    yData(:,i) = tempYData(:);
end

H = plot(xData,yData);
if ~isempty(varargin)
    set(H,varargin{:});
end
set(H,'marker','+','linestyle',':');

if Opt.excludefromlegend
    grfun.excludefromlegend(H);
end

end
