% # subsasgn
%
% Subscripted assignment to numeric time series
%
% ## Syntax
%
%     X(Dates) = Values
%     X(Dates, I, J, K, ...) = Values
%
%
% ## Input Arguments
%
% * `X` [ tseries ] - Tseries object that will be assigned new
% observations.
%
% * `Dates` [ numeric ] - Dates for which the new observations will be
% assigned.
%
% * `I`, `J`, `K`, ... [ numeric ] - References to 2nd and higher
% dimensions of the tseries object.
%
% * `Values` [ numeric ] - New observations that will assigned at specified
% dates.
%
%
% ## Output Arguments
%
% * `X` [ tseries ] - Tseries object with newly assigned observations.
%
%
% ## Description
%
%
% ## Example
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = subsasgn(this, s, y, varargin)

if isstruct(s) && isequal(s(1).type, '.')
    this = builtin('subsasgn', this, s, y);
    return
end

if ~isstruct(s)
    % Simplified syntax: subsasgn(x, dates, y, ref2, ref3, ...)
    dates = s;
    s = struct( );
    s.type = '()';
    s.subs = [{dates}, varargin];
end

switch s(1).type
    case {'()', '{}'}
        % Run recognizeShift( ) to tell if the first reference is a lag/lead. If yes, 
        % the startdate `x` will be adjusted within recognizeShift( )
        sh = 0;
        if numel(s)>1 || isa(y, 'TimeSubscriptable')
            [this, s, sh] = recognizeShift(this, s);
        end
        % After a lag or lead, only one ( )-reference is allowed
        if numel(s)~=1 || ~isequal(s(1).type, '()')
            exception.error([
                "TimeSubscriptable:InvalidSubscriptedAssignment"
                "Invalid subscripted assignment to time series; use round "
                "brackets to assign dated values to a time series."
            ]);
        end
        this = setData(this, s, y);

        % Shift start date back
        if sh~=0
            this.Start = dater.plus(this.Start, sh);
        end
end

end%

