% plot [Not a public function] Draw report/band object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function legendEntry = plot(this, Ax)

if any(strcmpi(this.options.plottype, {'patch', 'line'}))
    % Create the line plot first using the parent's method.
    [legendEntry, h, range, cData, xCoor] = plot@report.seriesobj(this, Ax);
    range = double(range);
    lData = getDataFromTo(this.Low{1}, range);
    hData = getDataFromTo(this.High{1}, range);
    series.band(Ax, h, cData, xCoor, lData, hData, this.options);
else
    [~, ~, ~, data] = errorbar(Ax, double(this.options.range), ...
        this.data{1}, this.Low{1}, this.High{1}, ...
        'relative', this.options.relative);
    legendEntry = mylegend(this, size(data, 2));
end

end%

