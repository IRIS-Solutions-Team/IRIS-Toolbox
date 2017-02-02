function X = normalise(X,NormDate,varargin)
% normalise  Normalise (or rebase) data to particular date.
%
%
% Syntax
% =======
%
%     X = normalise(X,NormDate,...)
%
%
% Input arguments
% ================
%
% * `x` [ tseries ] -  Input time series that will be normalised.
%
% * `NormDate` [ numeric | `'start'` | `'end'` | `'nanStart'` | `'nanEnd'`
% ] - Date relative to which the input data will be normalised; if not
% specified, `'nanStart'` (the first date for which all columns have an
% observation) will be used.
%
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Normalised time series.
%
%
% Options
% ========
%
% * `'mode='` [ `'add'` | *`'mult'`* ]  - Additive or multiplicative
% normalisation.
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

opt = passvalopt('tseries.normalise',varargin{:});

if ischar(NormDate)
    if isdatinp(NormDate)
        NormDate = textinp2dat(NormDate);
    else
        NormDate = get(X,NormDate);
    end
end

%--------------------------------------------------------------------------

if strncmpi(opt.mode,'add',3)
    func = @minus;
else
    func = @rdivide;
end

xSize = size(X.data);
X.data = X.data(:,:);

y = mygetdata(X,NormDate);
for i = 1 : size(X.data,2)
    X.data(:,i) = func(X.data(:,i),y(i));
end

if length(xSize) > 2
    X.data = reshape(X.data,xSize);
end

X = trim(X);

end
