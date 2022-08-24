function leg = plot(this, hAx)
% plot  Plot fanchart object.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team & Sergey Plotnikov.

%--------------------------------------------------------------------------

% Create the line plot first using the parent's method.
[leg, h, time, cData, grid] = plot@report.seriesobj(this, hAx);
grid = grid(:);
stdata = this.std(time);
probdata = this.prob;
nint = size(probdata, 1);
nextplot = get(hAx, 'nextPlot');
set(hAx, 'nextPlot', 'add');
pt = nan(1, nint);
stdata = stdata.*this.options.factor;
asym = this.options.asym;
if isa(asym, 'Series')
    asym = asym(time);
    asym(isnan(asym)) = 1;
end
lstData = stdata.*(2./(1 + asym));
hstData = stdata.*(2.*asym./(1+asym));
leg = [cell(1, nint) leg];

for i = 1 : nint
    whi = probdata(i);
    % ldata = -norminv(0.5*probdata(i)+0.5)*lstdata;
    lData = sqrt(2)*erfcinv(probdata(i)+1)*lstData;
    % hdata = norminv(0.5*probdata(i)+0.5)*hstdata;
    hData = -sqrt(2)*erfcinv(probdata(i)+1)*hstData;
    vData = [lData;flipud(hData)];
    vData = vData + [cData;flipud(cData)];
    pt(i) = fill([grid;flipud(grid)], vData, 'white');
    ch = get(hAx, 'children');
    ch(ch == pt(i)) = [ ];
    ch(end+1) = pt(i); %#ok<AGROW>
    set(hAx, 'children', ch);
    lineCol = get(h, 'color');
    faceCol = whi*[1, 1, 1] + (1-whi)*lineCol;
    if this.options.exclude(min([i, end]))
        faceCol = 'none';
    end
    set(pt(i), 'faceColor', faceCol, ...
        'edgeColor', 'none', ...
        'lineStyle', '-', ...
        'tag', 'fanchart', ...
        'userData', whi);
    lgd = this.options.fanlegend;
    if isequal(lgd, Inf)
        if this.options.exclude(min([i, end]))
            grfun.excludefromlegend(pt(i));
            leg(nint+1-i) = [ ];
        else
            leg{nint+1-i} = sprintf('%g%%', 100*whi);
        end;
    elseif iscell(lgd)
        if ~all(isnan(lgd{i})) && ~this.options.exclude(min([i, end]))
            leg{nint+1-i} = lgd{i};
        else
            grfun.excludefromlegend(pt(i));
            leg(nint+1-i) = [ ];
        end
    end
end

if isequaln(this.options.fanlegend, NaN)
    grfun.excludefromlegend(pt(:));
    leg(1:nint) = [ ];
end

set(hAx, 'nextPlot', nextplot);

end
