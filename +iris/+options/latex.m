function def = latex( )
% latex  Default options for latex package functions.
%
% Backend IRIS function.
% No help provided.

% The IRIS Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

def = struct( );

def.epstopdf = {
    'display', false, @(x) isequal(x, true) || isequal(x, false)
};

def.publish = { 
    'author', '', @ischar
    'cleanup', true, @(x) isequal(x, true) || isequal(x, false)
    'closeall', true, @(x) isequal(x, true) || isequal(x, false)
    'date', '\today', @ischar
    'cleanup', [ ], @(x) isempty(x) || islogicalscalar(x)
    'display', true, @(x) isequal(x, true) || isequal(x, false)
    'evalcode', true, @(x) isequal(x, true) || isequal(x, false)
    'event', '', @ischar
    'figureframe', false, @(x) isequal(x, true) || isequal(x, false)
    'figurescale', 0.75, @(x) isnumericscalar(x) && x>0
    'figuretrim', [50, 210, 50, 180], @(x) isnumeric(x) && numel(x)==4
    'figurewidth', '4in', @ischar
    'irisversion', true, @(x) isequal(x, true) || isequal(x, false)
    'linespread', 'auto', @(x) (ischar(x) && strcmpi(x, 'auto')) || isnumericscalar(x) && x>0
    'matlabversion', true, @(x) isequal(x, true) || isequal(x, false)
    'numbered', true, @(x) isequal(x, true) || isequal(x, false)
    'papersize', 'letterpaper', @(x) isequal(x, 'a4paper') || isequal(x, 'letterpaper')
    'preamble', '', @ischar
    'package', { }, @(x) iscellstr(x) || ischar(x) || isempty(x)
    'supertitle', '', @(x) isempty(x) || ischar(x)
    'template', 'paper', @(x) ischar(x) && any(strcmpi(x, {'paper', 'present'}))
    'textscale', 0.70, @isnumericscalar
    'toc', true, @(x) isequal(x, true) || isequal(x, false)
    'usenewfigure', false, @(x) isequal(x, true) || isequal(x, false)
};
end
