function LegendEntry = plot(This,Ax)
% plot [Not a public function] Draw report/band object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

if any(strcmpi(This.options.plottype,{'patch','line'}))
    % Create the line plot first using the parent's method.
    [LegendEntry,h,range,cData,xCoor] = plot@report.seriesobj(This,Ax);
    lData = rangedata(This.Low{1},range);
    hData = rangedata(This.High{1},range);
    tseries.myband(Ax,h,cData,xCoor,lData,hData,This.options);
else
    [~,~,~,data] = errorbar(Ax,This.options.range, ...
        This.data{1},This.Low{1},This.High{1}, ...
        'relative=',This.options.relative);
    LegendEntry = mylegend(This,size(data,2));
end

end
