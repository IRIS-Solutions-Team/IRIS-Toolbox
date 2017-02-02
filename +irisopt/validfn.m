function varargout = validfn( )
% validfn  Frequently used validators.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent FN_VALID;

%--------------------------------------------------------------------------

if ~isempty(FN_VALID) && isstruct(FN_VALID)
    varargout{1} = FN_VALID;
    return
end

FN_VALID = struct( );

FN_VALID.Display = @(x) ...
    isequal(x, @auto) || isequal(x, @default) || islogicalscalar(x) ...
    || (isintscalar(x) && x>=0) ...
    || any(strcmpi(x, {'iter*', 'iter', 'final', 'none', 'notify', 'off'}));

FN_VALID.figureopt = @(x) ...
    isempty(x) || ( iscell(x) && iscellstr(x(1:2:end)) );

FN_VALID.chksstate = @(x) islogicalscalar(x) ...
    || (iscell(x) && iscellstr(x(1:2:end)));

FN_VALID.matrixfmt = @(x) ischar(x) && any(strcmpi(x,{'plain','numeric'}));

FN_VALID.solve = @(x) islogicalscalar(x) ...
    || (iscell(x) && iscellstr(x(1:2:end)));

FN_VALID.sstate = @(x) islogical(x) ...
    || (iscell(x) && iscellstr(x(1:2:end))) ...
    || isa(x,'function_handle') ...
    || (iscell(x) && ~isempty(x) && isa(x{1},'function_handle'));

FN_VALID.subplot = @(x) ...
    isequal(x,@auto) ...
    || ( isnumeric(x) ...
    && any(length(x)==[1,2]) && all(isround(x)) && all(x>0) );

varargout{1} = FN_VALID;

end
