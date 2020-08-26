function def = tseries( )
% tseries  Default options for tseries class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

def = struct( );

def.band = { ...
    'excludefromlegend', true, @islogicalscalar, ...
    'grid', 'top', @(x) ischar(x) && any(strcmpi(x, {'top', 'bottom'})), ...
    'relative', true, @islogicalscalar, ...
    'white', 0.85, @(x) isnumeric(x) && all(x>=0) && all(x<=1), ...
};

def.errorbar = { ...
    'excludefromlegend', true, @islogicalscalar, ...
    'relative', true, @islogicalscalar, ...
};

def.fft = { ...
    'full', false, @islogicalscalar
};

def.barcon = {
    'barwidth', 0.8, @isnumericscalar, ...
    'colormap', [ ], @isnumeric, ...
    'evenlyspread', true, @islogicalscalar, ...
    'ordering', 'preserve', @(x) isanystri(x, {'descend', 'ascend', 'preserve'}) ...
    || isnumeric(x), ...
};

def.pct = {
    'outputfreq, freq', [ ], @(x) isempty(x) || (isnumericscalar(x) && any(x==[1, 2, 4, 6, 12]))
};

def.plotcmp = { 
    'compare', [-1;1], @isnumeric
    'cmpcolor, diffcolor', [1, 0.75, 0.75], @(x) isnumeric(x) && length(x)==3 && all(x>=0) && all(x<=1)
    'baseline', true, @(x) isequal(x, true) || isequal(x, false)
    'rhsplotfunc', [ ], @(x) isempty(x) || isequal(x, @bar) || isequal(x, @area) 
    'cmpplotfunc, diffplotfunc', @bar, @(x) isequal(x, @bar) || isequal(x, @area)
};

end%
