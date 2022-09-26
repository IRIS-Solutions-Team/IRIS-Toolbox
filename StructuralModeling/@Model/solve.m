% solve  Calculate first-order accurate solution of the model


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, exitFlag, info] = solve(this, varargin)

opt = prepareSolve(this, varargin{:});

if any(this.Link)
    this = refresh(this);
end

if opt.Warning
    % Warning if some parameters are NaN, or some log-lin variables have
    % non-positive steady state
    chkList = { 'parameters.dynamic', 'log' };
    if ~this.LinearStatus
        chkList = [ chkList, {'sstate'} ];
    end
    chkQty(this, Inf, chkList{:});
end

% Calculate solutions for all parameterisations, and store expansion
% matrices.
[this, info] = solveFirstOrder(this, Inf, opt);
exitFlag = info.ExitFlag;

if (opt.Warning || opt.Error) && ~all(hasSucceeded(info.ExitFlag))
    here_reportFailure( );
end

return

    function here_reportFailure()
        %(
        if opt.Error
            msgFunc = @(varargin) utils.error(varargin{:});
        else
            msgFunc = @(varargin) utils.warning(varargin{:});
        end
        [body, args] = solveFail(this, info);
        msgFunc('model:solve', body, args{:});
        %)
    end%
end%

