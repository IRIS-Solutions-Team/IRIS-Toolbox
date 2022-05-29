% solve  Calculate first-order accurate solution of the model


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, exitFlag, info] = solve(this, varargin)

opt = prepareSolve(this, varargin{:});

% Refresh dynamic links
if any(this.Link)
    this = refresh(this);
end

if opt.Warning
    % Warning if some parameters are NaN, or some log-lin variables have
    % non-positive steady state
    chkList = { 'parameters.dynamic', 'log' };
    if ~this.IsLinear
        chkList = [ chkList, {'sstate'} ];
    end
    chkQty(this, Inf, chkList{:});
end

% Calculate solutions for all parameterisations, and store expansion
% matrices.
[this, info] = solveFirstOrder(this, Inf, opt);
exitFlag = info.ExitFlag;

if (opt.Warning || opt.Error) && any(info.ExitFlag~=1)
    hereReportFailure( );
end

return

    function hereReportFailure( )
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

