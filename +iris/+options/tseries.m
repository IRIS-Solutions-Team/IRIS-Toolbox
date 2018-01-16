function def = tseries( )
% tseries  Default options for tseries class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

dates = iris.options.dates( );

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


convert = {
    'function', [ ], @(x) isempty(x) || isfunc(x) || ischar(x)
    'missing', NaN, @(x) (ischar(x) && any(strcmpi(x, {'last'}))) || isnumericscalar(x)
    'method', @mean, @(x) isfunc(x) || (ischar(x) && any(strcmpi(x, {'first', 'last'})))
    'select', Inf, @(x) isnumeric(x)
    'ConversionMonth, standinmonth', 1, @(x) isnumericscalar(x) || isequal(x, 'first') || isequal(x, 'last')
};


def.convertaggregdaily = [
    convert
    {
        'ignorenan', true, @(x) isequal(x, true) || isequal(x, false)
    }
];


def.convertaggreg = [
    convert
    {
        'ignorenan', true, @(x) isequal(x, true) || isequal(x, false)
    }
];


def.convertinterp = [
    convert
    {
    'ignorenan', true, @(x) isequal(x, true) || isequal(x, false)
    'method', 'pchip', @(x) ischar(x)
    'position', 'centre', @(x) ischar(x) && any(strncmpi(x, {'c', 's', 'e'}, 1))
    }
];

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

def.plot = [
    dates.datxtick
    {
    'function', [ ], @(x) isempty(x) || isfunc(x)
    'tight', false, @islogicalscalar
    'xlimmargin', @auto, @(x) islogicalscalar(x) || isequal(x, @auto)
    }
];

def.interp = { ...
    'method', 'pchip', @ischar, ...
};

def.barcon = {
    'barwidth', 0.8, @isnumericscalar, ...
    'colormap', [ ], @isnumeric, ...
    'evenlyspread', true, @islogicalscalar, ...
    'ordering', 'preserve', @(x) isanystri(x, {'descend', 'ascend', 'preserve'}) ...
    || isnumeric(x), ...
};

def.normalise = { ...
    'mode', 'mult', @(x) any(strncmpi(x, {'add', 'mult'}, 3)), ...
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

def.plotpred = { 
    'connect', true, @(x) isequal(x, true) || isequal(x, false)
    'firstline', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    'predlines', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    'firstmarker, firstmarkers, startpoint, startpoints', '.', @(x) ischar(x) && any(strcmpi(x, {'none', '+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'}))
    'shownanlines', true, @(x) isequal(x, true) || isequal(x, false)
};

def.plotyy = [
    def.plot
    {
        'coincide, coincident', false, @(x) isequal(x, true) || isequal(x, false)
        'highlight', [ ], @isnumeric
        'lhsplotfunc', @plot, @(x) ischar(x) || isfunc(x)
        'rhsplotfunc', @plot, @(x) ischar(x) || isfunc(x)
        'lhstight', false, @(x) isequal(x, true) || isequal(x, false)
        'rhstight', false, @(x) isequal(x, true) || isequal(x, false) 
    }
];

def.spy = [
    def.plot
    {
        'ShowTrue', true, @(x) isequal(x, true) || isequal(x, false)
        'ShowFalse', false, @(x) isequal(x, true) || isequal(x, false)
        'Squeeze', false, @(x) isequal(x, true) || isequal(x, false)
        'Names, Name', { }, @iscellstr
        'Test', @isfinite, @(x) isfunc(x)
    }
];

def.x12 = { ...
    'backcast, backcasts', 0, @(x) isscalar(x) && isnumeric(x)
    'cleanup, deletetempfiles, deletetempfile, deletex12file, deletex12file, delete', true, @(x) isequal(x, true) || isequal(x, false)
    'dummy', [ ], @(x) isempty(x) || isa(x, 'TimeSubscriptable')
    'dummytype', 'holiday', @(x) ischar(x) && any(strcmpi(x, {'holiday', 'td', 'ao'}))
    'display', false, @(x) isequal(x, true) || isequal(x, false)
    'forecast, forecasts', 0, @(x) isscalar(x) && isnumeric(x)
    'log', false, @(x) isequal(x, true) || isequal(x, false)
    'MaxIter', 1500, @(x) isscalar(x) && isnumeric(x) && x==round(x) && x>0
    'maxorder', [2, 1], @(x) isnumeric(x) && length(x)==2 && any(x(1)==[1, 2, 3, 4]) && any(x(2)==[1, 2])
    'missing', false, @(x) isequal(x, true) || isequal(x, false)
    'mode', 'auto', @(x) (isnumeric(x) && any(x==(-1 : 3))) || any(strcmp(x, {'add', 'a', 'mult', 'm', 'auto', 'sign', 'pseudo', 'pseudoadd', 'p', 'log', 'logadd', 'l'}))
    'output', 'd11', @(x) ischar(x) || iscellstr(x)
    'saveas', '', @ischar
    'specfile', 'default', @(x) ischar(x) || isinf(x)
    'tdays, tday', false, @(x) isequal(x, true) || isequal(x, false)
    'tempdir', '.', @(x) ischar(x) || isfunc(x)
    'tolerance', 1e-5, @(x) isnumericscalar(x) && x>0
};

end
