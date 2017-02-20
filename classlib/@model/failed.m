function varargout = failed(this, okSstate, okChkSstate, lsSstateErr, ...
    nPath, nanDerv, sing2, bk)
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
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

persistent STORE;

if nargin==0
    varargout{1} = STORE;
    return
end

STORE = this;

if ~okSstate
    c = utils.error('model:failed', ...
        'Steady state failed to converge on current parameters.');
elseif ~okChkSstate
    c = utils.error('model:failed', ...
        'Steady-state error in this equation: ''%s''.', ...
        lsSstateErr{:});
else
    [body, args] = solveFail(this, nPath, nanDerv, sing2, bk);
    c = utils.error('model:failed',body,args{:});
end

utils.error('model:failed', ...
    ['The model failed to update parameters and solution.',...
    '\n\n', ...
    'Type <a href="matlab: x = model.failed( );">', ...
    'x = model.failed( );', ...
    '</a> to get the model object that failed to solve.',...
    '\n\n',c,]);

end
