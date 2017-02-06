function def = FAVAR( )
% FAVAR   Default options for FAVAR class functions.

%--------------------------------------------------------------------------

def = struct( );

def.estimate = {
    'cross', true, @(x) islogicalscalar(x) || (isnumericscalar(x) && x>=0 && x<=1)
    'method', 'auto', @(x) isequal(x, 'auto') || isequal(x, 1) || isequal(x, 2)
    'order', 1, @(x) isnumericscalar(x)
    'rank', Inf, @(x) isnumericscalar(x)
    'tolerance', 'auto', @(x) isequal(x, 'auto') || isnumericscalar(x)
    'ynames, yname', @(n) ['y', sprintf('%g', n)], @(x) iscellstr(x) || isa(x, 'function_handle')
    };

def.filter = { 
    'cross', true, @(x) islogicalscalar(x) || (isnumericscalar(x) && x>=0 && x<=1)
    'invfunc', 'auto', @(x) isequal(x, 'auto') || isa(x, 'function_handle')
    'meanonly', false, @islogicalscalar
    'persist', false, @islogicalscalar
    'tolerance', 0, @isnumericscalar
    };

def.forecast = {
    'cross', true, @(x) islogicalscalar(x) || (isnumericscalar(x) && x>=0 && x<=1)
    'invfunc', 'auto', @(x) isequal(x, 'auto') || isa(x, 'function_handle')
    'meanonly', false, @islogicalscalar
    'persist', false, @islogicalscalar
    'tolerance', 0, @isnumericscalar
    };

end
