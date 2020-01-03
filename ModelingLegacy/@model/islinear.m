function flag = islinear(this)
% islinear  True for models declared as linear.
%
% Syntax
% =======
%
%     Flag = islinear(M)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Queried model object.
%
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the model has been declared
% linear.
%
%
% Description
% ============
%
% The value returned dependes on whether the model has been declared as
% linear by the user when constructing the model object by calling the
% [`model/model`](model/model) function. In other words, no check is
% performed whether or not the model is actually linear.
%
%
% Example
% ========
%
%     m = model('mymodel.file', 'linear=', true);
%     islinear(m)
%     ans =
%          1
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

flag = this.IsLinear;

end