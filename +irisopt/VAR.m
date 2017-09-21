function Def = VAR( )
% VAR  Default options for VAR class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct( );

outputFmt = {
    'output', 'auto', @(x) any(strcmpi(x, {'auto', 'dbase', 'tseries', 'array'}))
};


matrixFormat = {
    'MatrixFormat', 'namedmat', @namedmat.validateMatrixFormat
};


applyFilter = { 
    'applyto', @all, @(x) isnumeric(x) || islogical(x) || isequal(x, @all) || iscellstr(x)
    'filter', '', @ischar
};


tolerance = {
    'tolerance', getrealsmall( ), @isnumericscalar
};


Def.acf = [
    applyFilter
    matrixFormat
    {
    'nfreq', 256, @isnumericscalar
    'order', 0, @isnumericscalar
    'progress', false, @islogicalscalar
    }; %#ok<*CCAT>
];


Def.estimate = [ 
    outputFmt
    {
    'a', [ ], @isnumeric
    'bvar', [ ], @(x) isempty(x) || isa(x, 'BVAR.bvarobj')
    'c', [ ], @isnumeric    
    'j', [ ], @isnumeric
    'diff', false, @islogicalscalar
    'g', [ ], @isnumeric
    'order', 1, @(x) isnumeric(x) && numel(1) == 1
    'cointeg', [ ], @isnumeric
    'comment', '', @(x) ischar(x) || isequal(x, Inf)
    'constraints, constraint', '', @(x) ischar(x) || iscellstr(x) || isnumeric(x)
    'constant, const, constants', true, @islogicalscalar
    'covparameters, covparameter, covparam', false, @islogicalscalar
    'eqtnbyeqtn', false, @islogicalscalar
    'MaxIter', 1, @isnumericscalar
    'mean', [ ], @(x) isempty(x) || isnumeric(x)
    'progress', false, @islogicalscalar
    'schur', true, @islogicalscalar
    'stdize', false, @islogicalscalar
    'tolerance', 1e-5, @isnumericscalar
    'timeweights', [ ], @(x) isempty(x) || isa(x, 'tseries')
    'ynames, yname', { }, @iscellstr
    'warning', true, @islogicalscalar
    ... Panel VARs
    'fixedeff, fixedeffect', true, @islogicalscalar
    'groupweights', [ ], @(x) isempty(x) || isnumeric(x)
    'groupspec', false, @(x) islogicalscalar(x) || iscellstr(x) || ischar(x)
    }
];

Def.filter = {
    'ahead', 1, @(x) isnumeric(x) || isround(x) || x >= 1
    'cross', true, @(x) islogicalscalar(x) || (isnumericscalar(x) && x >=0 && x <= 1)
    'deviation, deviations', false, @islogicalscalar
    'meanonly', false, @islogicalscalar
    'omega', [ ], @isnumeric
    'output', 'smooth', @ischar    
};

Def.fmse = [
    matrixFormat
]; %#ok<CCAT1>

Def.forecast = [
    outputFmt
    {
    'cross', true, @(x) islogicalscalar(x) || (isnumericscalar(x) && x >=0 && x <= 1)
    'dboverlay, dbextend', false, @islogicalscalar
    'deviation, deviations', false, @islogicalscalar
    'meanonly', false, @islogicalscalar
    'omega', [ ], @isnumeric
    'returninstruments, returninstrument', true, @islogicalscalar
    'returnresiduals, returnresidual', true, @islogicalscalar
    }
];

Def.integrate = {
    'applyto', Inf, @(x) isnumeric(x) || islogical(x)
    };

Def.isexplosive = [
    tolerance
]; %#ok<CCAT1>

Def.isstationary = [
    tolerance
]; %#ok<CCAT1>


Def.portest = {
    'level', 0.05, @(x) isnumericscalar(x) && x > 0 && x < 1
    };

Def.resample = [
    outputFmt
    {
    'deviation, deviations', false, @islogicalscalar   
    'method', 'montecarlo', @(x) isfunc(x) ...
    || (ischar(x) && any(strcmpi(x, {'montecarlo', 'bootstrap'})))
    'progress', false, @islogicalscalar
    'randomise, randomize', false, @islogicalscalar
    'wild', false, @islogicalscalar
    }
];

Def.simulate = [
    outputFmt
    {
    'contributions, contribution', false, @islogicalscalar
    'deviation, deviations', false, @islogicalscalar
    'returnresiduals, returnresidual', true, @islogicalscalar
    }
];

Def.sprintf = {
    'constant, constants, const', true, @islogicalscalar
    'decimal', [ ], @(x) isempty(x) || isnumericscalar(x)
    'declare', false, @islogicalscalar
    'enames, ename', [ ], @(x) isempty(x) || iscellstr(x) || isfunc(x)
    'format', '%+.16g', @ischar
    'hardparameters, hardparameter', true, @islogicalscalar
    'tolerance', getrealsmall( ), @isnumericscalar
    'ynames, yname', [ ], @(x) isempty(x) || iscellstr(x)
    };

Def.response = {
    'presample', false, @islogicalscalar
    'select', Inf, @(x) isequal(x, Inf) || islogical(x) || isnumeric(x) || ischar(x) || iscellstr(x)
    };

Def.VAR = {
    'exogenous', { }, @(x) ischar(x) || iscellstr(x)
    };

Def.xsf = [
    applyFilter
    {
    'progress', false, @islogicalscalar
    }
];

end
