function excludefromlegend(h)
% excludefromlegend  Exclude graphic object from legend.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

for i = 1 : numel(h)
    try %#ok<TRYNC>
        if true % ##### MOSW
            set(get(get(h(i), 'Annotation'), 'LegendInformation'),...
                'IconDisplayStyle', 'Off');
        else
            setappdata(h(i), 'IRIS_EXCLUDE_FROM_LEGEND', true); %#ok<UNRCH>
        end
    end
end

end
