% excludeFromLegend  Exclude graphics objects from legend
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function excludeFromLegend(h)

for i = 1 : numel(h)
    try %#ok<TRYNC>
        set(get(get(h(i), 'annotation'), 'legendInformation'), 'iconDisplayStyle', 'off');
    end
end

end%

