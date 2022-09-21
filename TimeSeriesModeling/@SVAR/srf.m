function varargout = srf(this, time, varargin)
% srf  Shock response function
%
% __Syntax__
%
%     [Resp, Cum] = srf(V, NPer)
%     [Resp, Cum] = srf(V, Range)
%
%
% __Input Arguments__
%
% * `V` [ SVAR ] - SVAR object for which the impulse response function will
% be computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
%
% __Output Arguments__
%
% * `Resp` [ tseries | struct ] - Shock response functions.
%
% * `Cum` [ tseries | struct ] - Cumulative shock response functions.
%
%
% __Options__
%
% * `'presample='` [ `true` | *`false`* ] - Include zeros for pre-sample
% initial conditions in the output data.
%
% * `'select='` [ cellstr | char | logical | numeric | *`Inf`* ] -
% Selection of shocks to which the responses will be simulated.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.


islogicalscalar = @(x) islogical(x) && isscalar(x);
defaults = {
    'presample', false, islogicalscalar
    'select', Inf, @(x) isequal(x, Inf) || islogical(x) || isnumeric(x) || ischar(x) || iscellstr(x) || isstring(x)
};

opt = passvalopt(defaults, varargin{:});

[indexSelected, namesInvalid] = myselect(this, 'e', opt.select);
if ~isempty(namesInvalid)
    throw( ...
        exception.Base('SVAR:InvalidSelection', 'error'), ...
        'error ', ...
        namesInvalid{:} ...
    );
end

[varargout{1:nargout}] = myresponse(this, time, this.B, indexSelected, opt);

end%

