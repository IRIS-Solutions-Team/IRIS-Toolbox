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

