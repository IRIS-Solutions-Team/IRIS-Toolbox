function aa = ftitle(varargin)
% ftitle  Add title to figure window.
%
% Syntax
% =======
%
%     aa = grfun.ftitle(titles, ...)
%     aa = grfun.ftitle(ff, titles, ...)
%
%
% Input arguments
% ================
%
% * `ff` [ numeric | struct ] - Handle to a figure window or windows; or a
% struct that includes a field name `figure`.
%
% * `titles` [ cellstr | char ] - Text string to be centred, or cell array
% of strings to be placed on the LHS, centred, and on the RHS of the
% figure.
%
%
% Output arguments
% =================
%
% * `aa` [ cell ] - Cell array of handles to annotation objects created,
% one cell for each figure; each cell contains up to three handles
% depending on `'titles'`.
%
%
% Options
% ========
%
% * `'Location='` [ *`'north'`* | `'west'` | `'east'` | `'south'` ] -
% Location of the figure title: top, left edge sideways, right edge
% sideways, bottom.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

DEFAULT_FONT_NAME = get(0, 'DefaultAxesFontName');

if all(ishandle(varargin{1}(:)))
    ff = varargin{1};
    varargin(1) = [ ];
elseif isstruct(varargin{1}) ...
        && isfield(varargin{1}, 'figure') ...
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
        string = {'', '', ''};
    case 1
        string = [{''}, string, {''}];
    case 2
        string = [string, {''}];
end


defaults = { 
    'location', 'north', @(x) validate.anyString(x, "north", "west", "east", "south")
};

[opt, varargin] = passvalopt(defaults, varargin{:});


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
    'Margin', 0, ...
    };

nff = numel(ff);
aa = cell(1, nff);
for i = 1 : nff
    aa{i} = annotate( );
end

return




    function a = annotate( )
        a = [ ];
        fontSize = get(0, 'defaultAxesFontSize') * 1.15;
        if ~isempty(string{1})
            a = [ a, ...
                annotation(ff(i), 'TextBox', [x1, y1, 0, 0], ...
                'FitBoxToText', 'on', ...
                'String', string{1}, ...
                'FontSize', fontSize, ...
                'HorizontalAlignment', 'left', ...
                textOpt{:}, varargin{:}) ];
        end
        if ~isempty(string{2})
            a = [ a, ...
                annotation(ff(i), 'TextBox', [x2, y2, 0, 0], ...
                'FitBoxToText', 'on', ...
                'String', string{2}, ...
                'FontSize', fontSize, ...
                'HorizontalAlignment', 'center', ...
                textOpt{:}, varargin{:}) ];
            set(ff(i), 'Name', string{2});
        end
        if ~isempty(string{3})
            a = [ a, ...
                annotation(ff(i), 'TextBox', [x3, y3, 0, 0], ...
                'FitBoxToText', 'on', ...
                'String', string{3}, ...
                'FontSize', fontSize, ...
                'HorizontalAlignment', 'right', ...
                textOpt{:}, varargin{:}) ];
        end
    end
end
