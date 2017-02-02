function X = pct(X,S,varargin)
% pct  Percent rate of change.
%
% Syntax
% =======
%
%     X = pct(X)
%     X = pct(X,K,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
% * `K` [ numeric ] - Time shift over which the rate of change will be
% computed, i.e. between time t and t+k; if not specified `K` will be set
% to `-1`.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Percentage rate of change in the input data.
%
% Options
% ========
%
% * `'outputFreq='` [ `1` | `2` | `4` | `6` | `12` | *empty* ] - Convert
% the rate of change to the requested date frequency; empty means plain
% rate of change with no conversion.
%
% Description
% ============
%
% Example
% ========
%
% In this example, `x` is a monthly time series. The following command
% computes the annualised rate of change between month t and t-1:
%
%     pct(x,-1,'outputfreq=',1)
%
% while the following line computes the annualised rate of change between
% month t and t-3:
%
%     pct(x,-3,'outputFreq=',1)
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    S; %#ok<VUNUS>
catch %#ok<CTCH>
    S = -1;
end

opt = passvalopt('tseries.pct',varargin{:});

%--------------------------------------------------------------------------

if isempty(X.data)
    return
end

Q = 1;
if ~isempty(opt.outputfreq)
    inpFreq = datfreq(X.start);
    Q = inpFreq / opt.outputfreq / abs(S);
end

% @@@@@ MOSW
X = unop(@(varargin) tseries.mypct(varargin{:}),X,0,S,Q);

end
