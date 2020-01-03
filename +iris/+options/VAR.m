function def = VAR( )
% VAR  Default options for VAR class functions
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

def = struct( );

outputFmt = {
    'output', 'auto', @(x) any(strcmpi(x, {'auto', 'dbase', 'tseries', 'array'}))
};


matrixFormat = {
    'MatrixFormat', 'namedmat', @namedmat.validateMatrixFormat
};


applyFilter = { 
    'ApplyTo', @all, @(x) isnumeric(x) || islogical(x) || isequal(x, @all) || iscellstr(x)
    'Filter', '', @ischar
};


def.acf = [
    applyFilter
    matrixFormat
    {
    'NFreq', 256, @isnumericscalar
    'Order', 0, @isnumericscalar
    'Progress', false, @islogicalscalar
    }; %#ok<*CCAT>
];


def.filter = {
};

def.fmse = [
    matrixFormat
]; %#ok<CCAT1>

def.forecast = [
    outputFmt
    {
    'cross', true, @(x) islogicalscalar(x) || (isnumericscalar(x) && x >=0 && x <= 1)
    'dboverlay, dbextend', false, @islogicalscalar
    'Deviation, Deviations', false, @islogicalscalar
    'meanonly', false, @islogicalscalar
    'omega', [ ], @isnumeric
    'returninstruments, returninstrument', true, @islogicalscalar
    'returnresiduals, returnresidual', true, @islogicalscalar
    'E', [ ], @(x) isempty(x) || isnumeric(x) 
    'Sigma', [ ], @isnumeric
    }
];

def.integrate = {
    'applyto', Inf, @(x) isnumeric(x) || islogical(x)
    };


def.portest = {
    'level', 0.05, @(x) isnumericscalar(x) && x > 0 && x < 1
    };

def.resample = [
    outputFmt
    {
    'Deviation, Deviations', false, @islogicalscalar   
    'method', 'montecarlo', @(x) isfunc(x) ...
    || (ischar(x) && any(strcmpi(x, {'montecarlo', 'bootstrap'})))
    'progress', false, @islogicalscalar
    'randomise, randomize', false, @islogicalscalar
    'wild', false, @islogicalscalar
    }
];

def.response = {
    'presample', false, @islogicalscalar
    'select', Inf, @(x) isequal(x, Inf) || islogical(x) || isnumeric(x) || ischar(x) || iscellstr(x)
    };

def.VAR = {
    'exogenous', { }, @(x) ischar(x) || iscellstr(x)
    };

end%

