function varargout = srf(This,Time,varargin)
% srf  Shock (impulse) response function.
%
% Syntax
% =======
%
%     [Resp,Cum] = srf(V,NPer)
%     [Resp,Cum] = srf(V,Range)
%
% Input arguments
% ================
%
% * `V` [ SVAR ] - SVAR object for which the impulse response function will
% be computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% * `Resp` [ tseries | struct ] - Shock response functions.
%
% * `Cum` [ tseries | struct ] - Cumulative shock response functions.
%
% Options
% ========
%
% * `'presample='` [ `true` | *`false`* ] - Include zeros for pre-sample
% initial conditions in the output data.
%
% * `'select='` [ cellstr | char | logical | numeric | *`Inf`* ] -
% Selection of shocks to which the responses will be simulated.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

opt = passvalopt('VAR.response',varargin{:});

%--------------------------------------------------------------------------

[select,invalid] = myselect(This,'e',opt.select);
if ~isempty(invalid)
    utils.error('SVAR:srf', ...
        'This residual name does not exist in the SVAR object: ''%s''.', ...
        invalid{:});
end

[varargout{1:nargout}] = myresponse(This,Time,This.B,select,opt);

end
