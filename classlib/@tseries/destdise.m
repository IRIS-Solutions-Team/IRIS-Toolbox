function This = destdise(This,XMean,XStd)
% destdise  Destandardise tseries object by applying specified standard deviation and mean to it.
%
% Syntax
% =======
%
%     X = destdise(X,XMean,XStd)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
% * `XMean` [ numeric ] - Mean that will be added the data.
%
% * `XStd` [ numeric ] - Standard deviation that will be added to the data.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Destandardised output data.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('XMean',@isnumeric);
pp.addRequired('XStd',@isnumeric);
pp.parse(XMean,XStd);

%--------------------------------------------------------------------------

% Check size conformity.
s1 = size(This);
s2 = size(XMean);
s3 = size(XStd);

if any(s1(2:end) ~= s2(2:end))
    utils.error('tseries:destdise', ...
        ['Size of input data and mean must agree ', ...
        'in 2nd and higher dimensions.']);
end

if any(s1(2:end) ~= s3(2:end))
    utils.error('tseries:destdise', ...
        ['Size of input data and std devs must agree ', ...
        'in 2nd and higher dimensions.']);
end

% @@@@@ MOSW
This = unop(@(varargin) tseries.mydestdize(varargin{:}),This,0,XMean,XStd);

end
