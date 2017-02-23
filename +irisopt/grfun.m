function def = grfun( )
% grfun  Default options for the +grfun package.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

def = struct( );

validFn = irisopt.validfn( );

caption = { 
    'caption', '', @ischar
    'vposition', 'top' @(x) (isnumericscalar(x) && x>=0 && x<=1) || (ischar(x) && any(strcmpi(x, {'top', 'bottom', 'centre', 'center', 'middle'})))
    'hposition', 'right', @(x) ischar(x) && any(strcmpi(x, {'right', 'left', 'centre', 'center', 'middle'}))
    };

def.bardatatips = { 
    'format', '%g', @ischar
    };

def.infline = [
    caption
    {
    'excludefromlegend', true, @islogicalscalar
    'timeposition', 'middle', @(x) isanystri(x, {'middle', 'before', 'after'})
    } ]; %#ok<CCAT>

def.highlight = [ 
    caption
    {
    'around', NaN, @isnumericscalar
    'color, colour', 0.8*[1, 1, 1], @(x) (isnumeric(x) && length(x)==3) || ischar(x) || (isnumericscalar(x) && x>=0 && x<=1)
    'excludefromlegend', true, @islogicalscalar
    'transparent', 0, @(x) isnumericscalar(x) && x>=0 && x<=1
    } ]; %#ok<CCAT>

def.plotcircle = { 
    'fill', false, @islogicalscalar
    };

def.ploteig = { 
    'ucircle, unitcircle', true, @islogicalscalar
    'quadrants', true, @islogicalscalar
    };

def.plotmat = { 
    'colnames, colname', 'auto', @(x) isempty(x) || iscellstr(x) || ischar(x)
    'rownames, rowname', 'auto', @(x) isempty(x) || iscellstr(x) || ischar(x)
    'maxcircle', false, @islogicalscalar
    'naninf', 'X', @(x) ischar(x) && length(x)==1
    'scale', 'auto', @(x) (ischar(x) && strcmpi(x, 'auto')) || (isnumericscalar(x) && x>0)
    'showdiag', true, @islogicalscalar
    ... Bkw compatibility options:
    'frame', [ ], @(x) isempty(x) || islogicalscalar(x)
    };

def.plotneigh = { 
    'caption', [ ], @(x) isempty(x) || iscellstr(x)
    'plotobj', true, @(x) islogicalscalar(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'plotlik', true, @(x) islogicalscalar(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'plotest', {'marker=', '*', 'linestyle=', 'none', 'color=', 'red'}, @(x) islogicalscalar(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'plotbounds', {'color=', 'red'}, @(x) islogicalscalar(x)  || (iscell(x) && iscellstr(x(1:2:end)))
    'subplot', @auto, validFn.subplot
    'title', {'interpreter=', 'none'}, @(x) isempty(x) || islogicalscalar(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'linkaxes', false, @islogicalscalar
    };

def.plotpp = { 
    'Axes', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    'Caption', [ ], @(x) isempty(x) || iscellstr(x)
    'Describe, DescribePrior', @auto, @(x) isequal(x, @auto) || islogicalscalar(x)
    'KsDensity', [ ], @(x) isempty(x) || isintscalar(x)
    'Figure', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    'PlotInit', true, @(x) islogicalscalar(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'PlotMode', true, @(x) islogicalscalar(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'PlotPrior', true, @(x) islogicalscalar(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'PlotPoster', true, @(x) islogicalscalar(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'PlotBounds', @auto, @(x) islogicalscalar(x) || isequal(x, @auto) || (iscell(x) && iscellstr(x(1:2:end)))
    'Sigma', 3, @(x) isnumericscalar(x) && x>0
    'Subplot', @auto, validFn.subplot
    'Tight', true, @islogicalscalar
    'Title', true, @(x) islogicalscalar(x) || (iscell(x) && iscellstr(x(1:2:end)))
    'XLim, XLims', [ ], @(x) isempty(x) || isstruct( )
    };

def.ftitle = { 
    'location', 'north', @(x) isanystri(x, {'north', 'west', 'east', 'south'})
    };

def.title = { 
    'interpreter', 'latex', @(x) ischar(x) ...
    && any(strcmpi(x, {'latex', 'tex', 'none'}))
    };

def.fsection = { 
    'close', false, @islogicalscalar
    'addto', '', @ischar
    'orient, orientation', 'landscape', @(x) isempty(x) ...
    || (ischar(x) && any(strcmpi(x, {'landscape', 'portrait', 'tall'})))
    };

def.style = { 
    'cascade', true, @islogicalscalar
    'offset', 0, @isnumericscalar
    'warning', true, @islogicalscalar
    };

end
