function x = mean(this)
% mean  Mean of the observables used to standardise the input data.
%
% Syntax
% =======
%
%     x = mean(a)
%
% Input arguments
% ================
%
% * `a` [ FAVAR ] - FAVAR object.
%
% Output arguments
% =================
%
% * `x` [ numeric ] - Estimated mean for the vector of the FAVAR
% observables that has been used to destandardise the input data before
% running principal component estimation.
%
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%**************************************************************************

x = this.Mean;

end