function varargout = subsref(this, s, varargin)
% subsref  Subscripted reference function for tseries objects.
%
% Syntax returning numeric array
% ===============================
%
%     ... = x(dates)
%     ... = x(dates, ...)
%
%
% Syntax returning tseries object
% ================================
%
%     ... = x{dates}
%     ... = x{dates, ...}
%
%
% Input arguments
% ================
%
% * `x` [ Series ] - Time series.
%
% * `dates` [ dates.Date | numeric ] - Dates for which the time series
% observations will be returned, either as a numeric array or as another
% tseries object.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Handle a call from the Variable Editor.
d = dbstack( );
isVE = length(d)>1 && strcmp(d(2).file, 'arrayviewfunc.m');
if isVE
    varargout{1} = subsref(this.data, s);
    return
end

if isnumeric(s)
    % Simplified syntax: subsref(X, Dates, Ref2, Ref3, ...)
    dates = s;
    s = struct( );
    s.type = '()';
    s.subs = [{dates}, varargin];
end

% Time-recursive expressions.
if isanystr(s(1).type, {'{}', '()'}) && isa(s(1).subs{1}, 'trec')
    varargout{1} = xxTRecExp(this, s, inputname(1));
    return
end

% Run `mylagorlead` to tell if the first reference is a lag/lead. If yes, 
% the startdate of `x` will be adjusted withing `mylagorlead`.
[this, s] = mylagorlead(this, s);
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
        if strcmp(s(1).type, '.') && strcmp(s(1).subs, 'args')
            utils.error('tseries:subsref', ...
                ['In time-recursive expressions, tseries objects must ', ...
                'be always indexed by trec objects.']);
        end
        % Give standard access to public properties.
        varargout{1} = builtin('subsref', this, s);
end

end


% Subfunctions...


%**************************************************************************


function X = xxTRecExp(This, S, InpName)
nSubs = length(S(1).subs);
% All references in 2nd and higher dimensions must be integer scalars or
% vectors or colons.
valid = true(1, nSubs);
for i = 2 : nSubs
    s = S(1).subs{i};
    valid(i) = ( isnumeric(s) && ~isempty(s) && all(isround(s)) ) ...
        || strcmp(s, ':');
end
if any(~valid)
    utils.error('tseries:subsref', ...
        'Invalid reference to tseries object in recursive expression.');
end
% Date vector in trec object must have the same date frequency as the
% referenced tseries object.
tr = S(1).subs{1};
if ~isempty(tr.Dates) && ~isnan(This.start) ...
        && ~freqcmp(tr.Dates(1), This.start)
    utils.error('tseries:subsref', ...
        'Frequency mismatch in recursive expression.');
end
% Create tsydney object.
X = tsydney(This, InpName, S(1).subs{:});
end % xxTRecExp( )
