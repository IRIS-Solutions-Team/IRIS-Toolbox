function Aa = ftitle(varargin)
% ftitle  Add title to figure window.
%
% Syntax
% =======
%
%     Aa = grfun.ftitle(Titles,...)
%     Aa = grfun.ftitle(FF,Titles,...)
%
% Input arguments
% ================
%
% * `FF` [ numeric | struct ] - Handle to a figure window or windows; or a
% struct that includes a field name `figure`.
%
% * `Titles` [ cellstr | char ] - Text string to be centred, or cell array
% of strings to be placed on the LHS, centred, and on the RHS of the
% figure.
%
% Output arguments
% =================
%
% * `Aa` [ numeric ] - Handle or handles to annotation objects.
%
% Options
% ========
%
% * `'location='` [ *`'north'`* | `'west'` | `'east'` | `'south'` ] -
% Location of the figure title: top, left edge sideways, right edge
% sideways, bottom.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

DEFAULT_FONT_NAME = get(0, 'DefaultAxesFontName');

if all(ishandle(varargin{1}(:)))
    ff = varargin{1};
    varargin(1) = [ ];
elseif isstruct(varargin{1}) ...
        && isfield(varargin{1},'figure') ...
        && all(ishandle(varargin{1}.figure(:)))
    ff = varargin{1}.figure;
    varargin(1) = [ ];    
else
    ff = gcf( );
end

string = varargin{1};
varargin(1) = [ ];

if ischar(string)
    string = {string};
end

switch length(string)
    case 0
        string = {'','',''};
    case 1
        string = [{''},string,{''}];
    case 2
        string = [string,{''}];
end

[opt,varargin] = passvalopt('grfun.ftitle',varargin{:});

%--------------------------------------------------------------------------
%#ok<*AGROW>

string = regexprep(string, '[ ]*\\\\[ ]*', sprintf('\n'));

switch lower(opt.location)
    case 'north'
        x1 = 0;
        x2 = 0.5;
        x3 = 1;
        y1 = 0.99;
        y2 = 0.99;
        y3 = 0.99;
        rotation = 0;
        valign = 'top';
    case 'west'
        x1 = 0.01;
        x2 = 0.01;
        x3 = 0.01;
        y1 = 0;
        y2 = 0.5;
        y3 = 1;
        rotation = 90;
        valign = 'top';
    case 'east'
        x1 = 0.99;
        x2 = 0.99;
        x3 = 0.99;
        y1 = 1;
        y2 = 0.5;
        y3 = 0;
        rotation = -90;
        valign = 'top';
    case 'south'
        x1 = 0;
        x2 = 0.5;
        x3 = 1;
        y1 = 0;
        y2 = 0;
        y3 = 0;
        rotation = 0;
        valign = 'bottom';
end

textOpt = { ...
    'VerticalAlignment', valign, ...
    'FontWeight', 'bold', ...
    'FontName', DEFAULT_FONT_NAME, ...
    'LineStyle', 'none', ...
    'Margin', ishg2(0,0.0001), ...
    };

if ~ishg2( )
    textOpt = [textOpt,{ ...
        'Rotation',rotation, ...
        }];
end

Aa = [ ];
for iFig = ff(:).'
    if ishg2( )
        doHg2( );
    else
        doHg1( );
    end
end

return




    function doHg1( )
        ca = get(iFig,'currentAxes');
        ax = axes('position',[0,0,1,1],'parent',iFig,'visible','off');
        if ~isempty(string{1})
            Aa = [Aa, ...
                text(x1,y1,string{1}, ...
                'parent',ax,'horizontalAlignment','left', ...
                textOpt{:},varargin{:})];
        end
        if ~isempty(string{2})
            Aa = [Aa, ...
                text(x2,y2,string{2}, ...
                'parent',ax,'horizontalAlignment','center', ...
                textOpt{:},varargin{:})];
        end
        if ~isempty(string{3})
            Aa = [Aa, ...
                text(x3,y3,string{3}, ...
                'parent',ax, ...
                'horizontalAlignment','right', ...
                textOpt{:},varargin{:})];
        end
        set(iFig,'currentAxes',ca);
    end




    function doHg2( )
        fontSize = get(0,'defaultAxesFontSize') * 1.15;
        if ~isempty(string{1})
            Aa = [Aa, ...
                annotation('TextBox',[x1,y1,0,0], ...
                'FitBoxToText','on', ...
                'String',string{1}, ...
                'FontSize',fontSize, ...
                'HorizontalAlignment','left', ...
                textOpt{:},varargin{:})];
        end
        if ~isempty(string{2})
            Aa = [Aa, ...
                annotation(iFig,'TextBox',[x2,y2,0,0], ...
                'FitBoxToText','on', ...
                'String',string{2}, ...
                'FontSize',fontSize, ...
                'HorizontalAlignment','center', ...
                textOpt{:},varargin{:})];
            set(iFig, 'Name', string{2});
        end
        if ~isempty(string{3})
            Aa = [Aa, ...
                annotation('TextBox',[x3,y3,0,0], ...
                'FitBoxToText','on', ...
                'String',string{3}, ...
                'FontSize',fontSize, ...
                'HorizontalAlignment','right', ...
                textOpt{:},varargin{:})];
        end
    end
end
