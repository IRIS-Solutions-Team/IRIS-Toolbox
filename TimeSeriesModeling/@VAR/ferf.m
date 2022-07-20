function varargout = ferf(This,Time,varargin)
% ferf  Forecast error response function.
%
% Syntax
% =======
%
%     [R,C] = ferf(V,NPer)
%     [R,C] = ferf(V,Range)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object for which the forecast error response function
% will be computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% * `Resp` [ tseries | struct ] - Forecast error response functions.
%
% * `Cum` [ tseries | struct ] - Cumulative forecast error response
% functions.
%
% Options
% ========
%
% * `'presample='` [ `true` | *`false`* ] - Include zeros for pre-sample
% initial conditions in the output data.
%
% * `'select='` [ cellstr | char | logical | numeric | *`Inf`* ] -
% Selection of variable to whose forecast errors the responses will be
% simulated.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.


islogicalscalar = @(x) islogical(x) && isscalar(x);
defaults = {
    'presample', false, islogicalscalar
    'select', Inf, @(x) isequal(x, Inf) || islogical(x) || isnumeric(x) || ischar(x) || iscellstr(x)
};

opt = passvalopt(defaults, varargin{:});


%--------------------------------------------------------------------------

[select,invalid] = myselect(This,'y',opt.select);
if ~isempty(invalid)
    utils.error('VAR:ferf', ...
        'This variable name does not exist in the VAR object: ''%s''.', ...
        invalid{:});
end

[varargout{1:nargout}] = myresponse(This,Time,[ ],select,opt);

end
