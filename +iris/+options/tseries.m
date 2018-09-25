function def = tseries( )
% tseries  Default options for tseries class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

def = struct( );

def.acf = { ...
    'demean', true, @islogicalscalar, ...
    'order', 0, @isnumericscalar, ...
    'smallsample', true, @islogicalscalar, ...
};

def.band = { ...
    'excludefromlegend', true, @islogicalscalar, ...
    'grid', 'top', @(x) ischar(x) && any(strcmpi(x, {'top', 'bottom'})), ...
    'relative', true, @islogicalscalar, ...
    'white', 0.85, @(x) isnumeric(x) && all(x>=0) && all(x<=1), ...
};

def.chowlin = { ...
    'constant', true, @islogicalscalar
    'log', false, @islogicalscalar
    'ngrid', 200, @(x) isnumericscalar(x) && x>=1
    'rho', 'estimate', @(x) any(strcmpi(x, {'auto', 'estimate', 'negative', 'positive'})) || (isnumericscalar(x) && x>-1 && x<1)
    'timetrend', false, @islogicalscalar
};

def.errorbar = { ...
    'excludefromlegend', true, @islogicalscalar, ...
    'relative', true, @islogicalscalar, ...
};

def.fft = { ...
    'full', false, @islogicalscalar
};

def.filter = { ...
    'Change, Growth', [ ], @(x) isempty(x) || isa(x, 'tseries')
    'Gamma', 1, @(x) isa(x, 'tseries') || (isnumericscalar(x) && x>0)
    'CutOff', [ ], @(x) isempty(x) || (isnumeric(x) && all(x(:)>0))
    'CutOffYear', [ ], @(x) isempty(x) || (isnumeric(x) && all(x(:)>0))
    'Drift', 0, @(x) isnumeric(x) && length(x)==1
    'Gap', [ ], @(x) isempty(x) || isa(x, 'tseries')
    'InfoSet', 2, @(x) isequal(x, 1) || isequal(x, 2)
    'Lambda', @auto, @(x) isequal(x, @auto) || isempty(x) || (isnumeric(x) && all(x(:)>0)) || (ischar(x) && strcmpi(x, 'auto'))
    'Level', [ ], @(x) isempty(x) || isa(x, 'tseries')
    'Log', false, @islogical
    'Swap', false, @islogical
    'Forecast', [ ], @(x) isnumeric(x) && length(x)<=1
};

def.clpf = {
    'Level', [ ], @isnumeric 
    'Change, Growth', [ ], @isnumeric
    'Order', 2, @(x) isintscalar(x) && x>0
    'InfoSet', 2, @(x) isequal(x, 2) || isequal(x, 1)
    'Gamma', 1, @isnumeric
    'Drift', 0, @isnumeric
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
