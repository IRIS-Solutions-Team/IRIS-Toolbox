function varargout ...
    = failed(This,SstateOk,ChkSstateOk,SstateErrList,NPath,NanDerv,Sing2)
% failed  Give access to the last failed model object.
%
% Syntax
% =======
%
%     M = model.failed( )
%
% Output arguments
% =================
%
% * `M` [ numeric ] - The model object with the parameterisation that
% failed to converge on steady state or to solve during one of the
% following functions: [`model/estimate`](model/estimate),
% [`model/diffloglik`](model/diffloglik), [`model/fisher`](model/fisher).
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% TODO: Write a separate function to produce the core of the message and
% share it with `model/solve`.

persistent STORE;

if nargin == 0
    varargout{1} = STORE;
    return
end

STORE = This;

if ~SstateOk
    c = utils.error('model:failed', ...
        'Steady state failed to converge on current parameters.');
elseif ~ChkSstateOk
    c = utils.error('model:failed', ...
        'Steady-state error in this equation: ''%s''.', ...
        SstateErrList{:});
else
    [body,args] = solveFail(This,NPath,NanDerv,Sing2);
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
