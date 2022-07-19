% solveFail  Create error/warning message when function solve fails
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [body, args] = solveFail(this, info)

%#ok<*AGROW>

BRX = sprintf('\n    ');

body = 'Solution not available for some parameter variant(s)';
args = { };
inxReportSaddlePath = info.ExitFlag==solve.StabilityFlag.NO_STABLE | info.ExitFlag==solve.StabilityFlag.MULTIPLE_STABLE;

while true
    ix = info.ExitFlag==solve.StabilityFlag.INVALID_STEADY;
    if any(ix)
        body = [body, BRX, ...
            'Model declared nonlinear, fails to solve ', ...
            'because of problems with steady state %s.'];
        args{end+1} = exception.Base.alt2str(ix);
        here_markAsProcessed();
        continue
    end

    ix = info.ExitFlag==solve.StabilityFlag.NAN_EIGEN;
    if any(ix)
        body = [body, BRX, ...
            'Singularity or linear dependency in some equations %s'];
        args{end+1} = exception.Base.alt2str(ix);
        here_markAsProcessed();
        continue
    end

    ix = info.ExitFlag==solve.StabilityFlag.NO_STABLE;
    if any(ix)
        body = [body, BRX, 'No stable solution %s'];
        args{end+1} = exception.Base.alt2str(ix);
        here_markAsProcessed();
        continue
    end

    ix = info.ExitFlag==solve.StabilityFlag.MULTIPLE_STABLE;
    if any(ix)
        body = [body, BRX, 'Multiple stable solutions %s'];
        args{end+1} = exception.Base.alt2str(ix);
        here_markAsProcessed();
        continue
    end

    ix = info.ExitFlag==solve.StabilityFlag.COMPLEX_SYSTEM;
    if any(ix)
        body = [body, BRX, 'Complex derivatives %s'];
        args{end+1} = exception.Base.alt2str(ix);
        here_markAsProcessed();
        continue
    end

    ix = info.ExitFlag==solve.StabilityFlag.NAN_SYSTEM;
    if any(ix)
        body = [body, BRX, 'NaNs in system matrices %s'];
        args{end+1} = exception.Base.alt2str(ix);
        here_markAsProcessed();
        continue
    end

    % Singularity in state space or steady state problem
    ix = info.ExitFlag==solve.StabilityFlag.NAN_SOLUTION;
    if any(ix)
        if any(info.Singularity(:))
            pos = find(any(info.Singularity, 2));
            pos = pos(:).';
            for ieq = pos
                body = [body, BRX, ...
                    'Singularity or NaN in this measurement equation %s: %s'];
                args{end+1} = exception.Base.alt2str(info.Singularity(ieq, :));
                args{end+1} = this.Equation.Input{ieq};
            end
        elseif ~this.LinearStatus && isnan(this, 'sstate')
            body = [body, BRX, ...
                'Model is declared nonlinear but some steady states are NaN', ...
                ];
            args{end+1} = exception.Base.alt2str(ix);
        else
            body = [body, BRX, ...
                'Singularity in state-space matrices %s'];
            args{end+1} = exception.Base.alt2str(ix);
        end
        here_markAsProcessed();
        continue
    end

    ix = info.ExitFlag==solve.StabilityFlag.NAN_SYSTEM;
    if any(ix)
        args = { };
        for ii = find(ix)
            for jj = find(info.InxNanDeriv{ii})
                body = [body, BRX, ...
                    'NaN in derivatives of this equation %s: %s'];
                args{end+1} = exception.Base.alt2str(ii);
                args{end+1} = this.Equation.Input{jj};
            end
        end
        here_markAsProcessed();
        continue
    end

    break
end

if any(inxReportSaddlePath)
    body = [ 
        body, BRX, ...
        '[Bkw variables, Unit roots, Stable roots]: ', ...
        sprintf( ...
            [ exception.Base.ALT2STR_DEFAULT_LABEL, '#%g[%g %g %g] ' ], ...
            [ find(inxReportSaddlePath); info.SaddlePath(:, inxReportSaddlePath) ] ...
        )
    ];
end

return

    function here_markAsProcessed()
        info.ExitFlag(ix) = solve.StabilityFlag.UNKNOWN;
    end%
end%
