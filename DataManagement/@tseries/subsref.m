function varargout = subsref(this, s, varargin)
% subsref  Subscripted reference function for tseries objects.
%
% __Syntax Returning Numeric Array__
%
%     ... = X(Dates)
%     ... = X(Dates, ...)
%
%
% __Syntax Returning tseries Object__
%
%     ... = X{Dates}
%     ... = X{Dates, ...}
%
%
% __Input Arguments__
%
% * `X` [ Series ] - Time series object.
%
% * `Dates` [ DateWrapper | numeric ] - Dates for which the time series
% observations will be returned, either as a numeric array or as another
% tseries object.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isnumeric(s)
    % Simplified syntax: subsref(X, Dates, Ref2, Ref3, ...)
    dates = s;
    s = struct( );
    s.type = '()';
    s.subs = [{dates}, varargin];
end

% Run recognizeShift( ) to tell if the first reference is a lag/lead; if yes, 
% the startdate of `x` will be adjusted within recognizeShift( )
[this, s] = recognizeShift(this, s);
if isempty(s)
    varargout{1} = this;
    return
end

switch s(1).type
    case '()'
        % Return numeric array.
        [data, range] = mygetdata(this, s(1).subs{:});
        varargout{1} = data;
        varargout{2} = range;
    case '{}'
        % Return Series object.
        [~, ~, this] = mygetdata(this, s(1).subs{:});
        s(1) = [ ];
        if isempty(s)
            varargout{1} = this;
        else
            varargout{1} = subsref(this, s);
        end
    otherwise
        % Give standard access to public properties.
        varargout{1} = builtin('subsref', this, s);
end

end
