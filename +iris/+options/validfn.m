function varargout = validfn( )
% validfn  Frequently used validators
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent FN_VALID

%--------------------------------------------------------------------------

if ~isempty(FN_VALID) && isstruct(FN_VALID)
    varargout{1} = FN_VALID;
    return
end

FN_VALID = struct( );

FN_VALID.figureopt = @(x) ...
    isempty(x) || ( iscell(x) && iscellstr(x(1:2:end)) );

FN_VALID.subplot = @(x) isequal(x, @auto) ...
                        || ( isnumeric(x) && any(length(x)==[1,2]) && all(x==round(x)) && all(x>0) );

varargout{1} = FN_VALID;

end
