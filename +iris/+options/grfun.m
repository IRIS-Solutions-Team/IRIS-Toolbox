function def = grfun( )
% grfun  Default options for the +grfun package.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

%--------------------------------------------------------------------------

def = struct( );

validFn = iris.options.validfn( );

def.bardatatips = { 
    'format', '%g', @ischar
};

def.plotcircle = { 
    'fill', false, @(x) isequal(x, true) || isequal(x, false)
};

def.ploteig = { 
    'ucircle, unitcircle', true, @(x) isequal(x, true) || isequal(x, false)
    'quadrants', true, @(x) isequal(x, true) || isequal(x, false)
};

def.plotmat = { 
    'colnames, colname', 'auto', @(x) isempty(x) || iscellstr(x) || ischar(x)
    'rownames, rowname', 'auto', @(x) isempty(x) || iscellstr(x) || ischar(x)
    'maxcircle', false, @(x) isequal(x, true) || isequal(x, false)
    'naninf', 'X', @(x) ischar(x) && length(x)==1
    'scale', 'auto', @(x) (ischar(x) && strcmpi(x, 'auto')) || (isnumeric(x) && isscalar(x) && x>0)
    'showdiag', true, @(x) isequal(x, true) || isequal(x, false)
    ... Bkw compatibility options:
    'frame', [ ], @(x) isempty(x) || isequal(x, true) || isequal(x, false)
};

def.plotneigh = { 
    'Caption', [ ], @(x) isempty(x) || iscellstr(x)
    'plotobj', true, @(x) isequal(x, true) || isequal(x, false) || iscellstr(x(1:2:end))
    'plotlik', true, @(x) isequal(x, true) || isequal(x, false) || iscellstr(x(1:2:end))
    'plotest', {'marker=', '*', 'linestyle=', 'none', 'color=', 'red'}, @(x) isequal(x, true) || isequal(x, false) || iscellstr(x(1:2:end))
    'plotbounds', {'color=', 'red'}, @(x) isequal(x, true) || isequal(x, false)  || iscellstr(x(1:2:end))
    'subplot', @auto, validFn.subplot
    'title', {'interpreter=', 'none'}, @(x) isempty(x) || isequal(x, true) || isequal(x, false) || iscellstr(x(1:2:end))
    'linkaxes', false, @(x) isequal(x, true) || isequal(x, false)
};

def.plotpp = { 
    'Axes', { }, @iscell
    'Caption', [ ], @(x) isempty(x) || iscellstr(x)
    'Describe, DescribePrior', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false)
    'KsDensity', [ ], @(x) isempty(x) || isintscalar(x)
    'Figure', { }, @iscell
    'PlotInit', true, @(x) isequal(x, true) || isequal(x, false) || iscell(x)
    'PlotMode', true, @(x) isequal(x, true) || isequal(x, false) || iscell(x)
    'PlotPrior', true, @(x) isequal(x, true) || isequal(x, false) || iscell(x)
    'PlotPoster', true, @(x) isequal(x, true) || isequal(x, false) || iscell(x)
    'PlotBounds', @auto, @(x) isequal(x, true) || isequal(x, false) || isequal(x, @auto) || iscell(x)
    'Sigma', 3, @(x) isnumeric(x) && isscalar(x) && x>0
    'Subplot', @auto, validFn.subplot
    'Tight', true, @(x) isequal(x, true) || isequal(x, false)
    'Title', true, @(x) isequal(x, true) || isequal(x, false) || iscell(x)
    'XLim, XLims', [ ], @(x) isempty(x) || isstruct( )
};

def.ftitle = { 
    'location', 'north', @(x) isanystri(x, {'north', 'west', 'east', 'south'})
};

def.title = { 
    'interpreter', 'latex', @(x) ischar(x) && any(strcmpi(x, {'latex', 'tex', 'none'}))
};

def.fsection = { 
    'close', false, @(x) isequal(x, true) || isequal(x, false)
    'addto', '', @ischar
    'orient, orientation', 'landscape', @(x) isempty(x) || (ischar(x) && any(strcmpi(x, {'landscape', 'portrait', 'tall'})))
};

def.style = { 
    'cascade', true, @(x) isequal(x, true) || isequal(x, false) 
    'offset', 0, @(x) isnumeric(x) && isscalar(x)
    'warning', true, @(x) isequal(x, true) || isequal(x, false)
};

end
