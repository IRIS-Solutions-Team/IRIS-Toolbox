function this = subsasgn(this, s, y, varargin)
% subsasgn  Subscripted assignment for time series
%{
% __Syntax__
%
%     X(Dates) = Values
%     X(Dates, I, J, K, ...) = Values
%
%
% __Input Arguments__
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
% __Output Arguments__
%
% * `X` [ tseries ] - Tseries object with newly assigned observations.
%
%
% __Description__
%
%
% __Example__
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if isstruct(s) && isequal(s(1).type, '.')
    % Give standard dot access to properties
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
        if length(s)>1 || isa(y, 'tseries')
            [this, s, sh] = recognizeShift(this, s);
        end
        % After a lag or lead, only one ( )-reference is allowed.
        if length(s)~=1 || ~isequal(s(1).type, '()')
            utils.error('tseries:subsasgn', ...
                ['Invalid subscripted assignment ', ...
                'to tseries object.']);
        end
        this = setData(this, s, y);
        % Shift start date back.
        if sh~=0
            this.Start = addTo(this.Start, sh);
        end
end

end%

