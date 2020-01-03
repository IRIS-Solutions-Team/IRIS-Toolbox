function P = myband(Ax, H, CData, XCoor, LData, HData, Opt)
% myband  Plot error bands aroud central line
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

BACKGROUND_LEVEL = -1;

%--------------------------------------------------------------------------

XCoor = XCoor(:);
LData = LData(:, :);
HData = HData(:, :);
nc = size(CData, 2);
nl = size(LData, 2);
nh = size(HData, 2);
nBand = max([nc, nl, nh]);
nw = length(Opt.white);
nextPlot = get(Ax, 'nextPlot');
set(Ax, 'nextPlot', 'add');
P = [ ];

% Base color(s) derived from center line(s).
col = get(H, 'color');
if ~iscell(col)
    col = { col };
end

for i = 1 : nBand
    if i <= nw
        white = Opt.white(i);
    elseif i > nc
        white = white^2;
    end
    
    % Retrieve current set of data.
    iCData = CData(:, min(i, end));
    iLData = LData(:, min(i, end));
    if Opt.relative && all( iLData(:) >=0 )
        iLData = -iLData;
    end
    iHData = HData(:, min(i, end));
    
    % Create x- and y-data for the patch function.
    xData = [ XCoor; flipud(XCoor) ];
    yData = [ iLData; flipud(iHData) ];
    if Opt.relative
        yData = yData + [ iCData; flipud(iCData) ];
    end
    
    % Remove data points where either xData or yData is NaN.
    ixNan = isnan(xData) | isnan(yData);
    if all(ixNan)
        continue
    end
    xData = xData(~ixNan);
    yData = yData(~ixNan);
    
    % Draw patch object, mix its face color.
    p = patch(xData, yData, 'white');
    faceCol = col{min(i, end)}; % white*[1, 1, 1] + (1-white)*col{min(i, end)};
    set( p, ...
         'FaceColor', faceCol, ...
         'FaceAlpha', 1-white, ...
         'EdgeColor', 'White', ...
         'LineStyle', '-', ...
         'Tag', 'band' );
    
    % Stack handles bottom up (same order as in axes children). Wider bands
    % need to be plotted before narrower bands.
    P = [p;P]; %#ok<AGROW>
end

set(Ax, 'nextPlot', nextPlot);

if isempty(P)
    return
end

for i = 1 : length(P)
    setappdata(P(i), 'IRIS_BackgroundLevel', BACKGROUND_LEVEL);
end
visual.backend.moveToBackground(P);


if Opt.excludefromlegend
    grfun.excludefromlegend(P);
end

end%

