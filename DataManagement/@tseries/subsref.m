function varargout = subsref(this, s, varargin)
% subsref  Subscripted reference function for time series
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if isstruct(s) && isequal(s(1).type, '.')
    % Give standartd dot access to properties
    [varargout{1:nargout}] = builtin('subsref', this, s);
    return
end

if ~isstruct(s)
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
        % Return numeric array
        [varargout{1:2}] = getData(this, s(1).subs{:});
    case '{}'
        % Return time series
        [~, ~, this] = getData(this, s(1).subs{:});
        s(1) = [ ];
        if isempty(s)
            varargout{1} = this;
        else
            varargout{1} = subsref(this, s);
        end
end

end%
