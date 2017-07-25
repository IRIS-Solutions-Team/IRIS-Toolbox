function this = single(this)
% single  Convert solution matrices to single precision.
%
% Syntax
% =======
%
%     m = single(m)
%
% Input arguments
% ================
%
% * `m` [ model ] - Model objects whose solution matrices will be converted
% to single precision.
%
% Output arguments
% =================
%
% * `m` [ model ] - Model objects single-precision solution matrices.
%
% Description
% ============

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%**************************************************************************

for i = 1 : length(this.solution)
    this.solution{i} = single(this.solution{i});
end

for i = 1 : length(this.Expand)
    this.Expand{i} = single(this.Expand{i});
end

end