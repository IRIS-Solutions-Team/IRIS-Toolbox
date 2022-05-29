function h = numericToHandle(h)
% numericToHandle  Convert numeric representation to graphics handle
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

currentAxes = visual.backend.getCurrentAxesIfExists( );
axes(h);
h = gca( );
if ~isempty(currentAxes)
    axes(currentAxes);
end

end
