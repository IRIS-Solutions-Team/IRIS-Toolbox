function yaxisreformat(varargin)
% yaxisreformat  Reformat the numeric ticks on the y axis.
%
% Syntax
% =======
%
%     yaxisreformat( )
%     yaxisreformat(NewFormat)
%     yaxisreformat(Ax,NewFormat)
%
% Input arguments
% ================
%
% * `NewFormat` [ char ] - New `sprintf` format for the numeric ticks; if
% not specified, the format will be determined automatically depending on
% the y-axis tick step size.
%
% * `Ax` [ numeric ] - Handle(s) to the axes that will be re-formatted.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if ~isempty(varargin) && all(ishghandle(varargin{1}))
    Ax = varargin{1};
    varargin(1) = [ ];
else
    Ax = gca( );
end

if ~isempty(varargin)
    NewFormat = varargin{1};
    varargin(1) = [ ]; %#ok<NASGU>
else
    NewFormat = 'auto';
end

%--------------------------------------------------------------------------

for ax = Ax(:).'
    yTick = get(ax,'yTick');
    if all(strcmpi(NewFormat,'auto'))
        d = max([0,-floor(log10(yTick(2)-yTick(1)))]);
        NewFormat = ['%.',sprintf('%g',d),'f'];
    end
    yTickString = cell(size(yTick));
    for j = 1 : length(yTick)
        yTickString{j} = sprintf(NewFormat,yTick(j));
    end
    set(ax,'yTickMode','manual', ...
        'yTickLabel',yTickString,'yTickLabelMode','manual');
end

end
