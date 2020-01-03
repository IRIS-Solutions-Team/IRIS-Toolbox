function varargout = failed( this, ...
                             okSteady, okCheckSteady, steadyErrors, ...
                             numOfPaths, nanDerv, sing2, bk )
% failed  Give access to the last failed model object.
%
% Syntax
% =======
%
%     m = model.failed( )
%
%
% Output arguments
% =================
%
% * `m` [ numeric ] - The model object with the parameterisation that
% failed to converge on steady state or to solve during one of the
% following functions: [`model/estimate`](model/estimate), 
% [`model/diffloglik`](model/diffloglik), [`model/fisher`](model/fisher).
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
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

persistent store

if nargin==0
    varargout{1} = store;
    return
end

store = this;

if ~okSteady
    c = utils.error('Model:Failed', ...
        'Steady state failed to converge on current parameters.');
elseif ~okCheckSteady
    c = utils.error('Model:Failed', ...
        'Steady-state error in this equation: ''%s''.', ...
        steadyErrors{:});
else
    [body, args] = solveFail(this, numOfPaths, nanDerv, sing2, bk);
    c = utils.error('Model:Failed', body, args{:});
end

utils.error('Model:Failed', ...
    ['The model failed to update parameters and solution ', ...
    '\n\n', ...
    'Type ', ...
    'x = model.failed( ) ', ...
    'to retrieve the model object that failed to solve ', ...
    '\n\n', c, ]);

end%

