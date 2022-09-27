%{
% 
% # `failed` ^^(Model)^^
% 
% {== Give access to the last failed model object ==}
% 
% 
% ## Syntax 
% 
%     m = Model.failed()
% 
% 
% 
% 
% ## Output arguments 
% 
% __`m`__ [ Model ] 
% > 
% >  The model object with the parameterisation that failed to converge on
% >  steady state or to solve during one of the following functions:
% >  [`estimate`](estimate.md),
% >  and [`fisher`](fisher.md).
% > 
% 
% ## Options 
% 
% 
% ## Description 
% 
% 
% ## Examples
% 
%}
% --8<--


function varargout = failed(this, steadySuccess, checkSteadySuccess, steadyErrors, solveInfo)

persistent store
if nargin==0
    varargout{1} = store;
    return
end

store = this;

if ~steadySuccess
    c = utils.error('Model:Failed', ...
        'Steady state failed to converge on current parameters.');
elseif ~checkSteadySuccess
    c = utils.error('Model:Failed', ...
        'Steady-state error in this equation: ''%s''.', ...
        steadyErrors{:});
else
    [body, args] = solveFail(this, solveInfo);
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

