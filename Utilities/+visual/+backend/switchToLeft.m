function switched = switchToLeft(axesHandle)
% switchToLeft  Switch to left y-axis if needed
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

switched = false;
if strcmp(get(axesHandle, 'YAxisLocation'), 'right')
    try
        yyaxis(axesHandle, 'left');
        switched = true;
    end
end

end
