function [legEnt, isExcluded] = mylegend(this, nData)
% mylegend  Create legend entries for report/series.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

isExcluded = false;

% The default legend entries (created when `'legend=' @auto`) consist of
% the series caption and a mark, unless the legend entries are supplied
% through the `'legend='` option.
if isequal(this.options.legendentry, @auto)
    % Produce default legend entries.
    legEnt = cell(1, nData);
    for i = 1 : nData
        name = this.caption;
        if i <= numel(this.options.marks)
            mark = this.options.marks{i};
        else
            mark = '';
        end
        if ~isempty(name) && ~isempty(mark)
            legEnt{i} = [name, ': ', mark];
        elseif isempty(mark)
            legEnt{i} = name;
        elseif isempty(name)
            legEnt{i} = mark;
        end
    end
elseif isequaln(this.options.legendentry, NaN)
    % Exclude the series from legend.
    legEnt = { };
    isExcluded = true;
elseif ischar(this.options.legendentry) || iscellstr(this.options.legendentry)
    % Use user-suppied legend entries.
    legEnt = cell(1, nData);
    if ischar(this.options.legendentry)
        this.options.legendentry = {this.options.legendentry};
    end
    this.options.legendentry = this.options.legendentry(:).';
    n = min(length(this.options.legendentry), nData);
    legEnt(1:n) = this.options.legendentry(1:n);
    legEnt(n+1:end) = {''};
else
    throw( ...
        exception.Base('Report:InvalidLegendEntries', 'error') ...
        );
end

end
