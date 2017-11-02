function excludeFromLegend(h)
% excludeFromLegend  Exclude graphic object from legend
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

for i = 1 : numel(h)
    try %#ok<TRYNC>
        set(get(get(h(i), 'Annotation'), 'LegendInformation'),...
            'IconDisplayStyle', 'Off');
    end
end

end
