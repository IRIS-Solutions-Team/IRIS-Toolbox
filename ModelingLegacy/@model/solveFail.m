% solveFail  Create error/warning message when function solve fails
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 IRIS Solutions Team

function [body, args] = solveFail(this, solveInfo)

%#ok<*AGROW>

BRX = sprintf('\n    ');

%--------------------------------------------------------------------------

body = 'Solution not available for some parameter variant(s)';
args = { };
inxReportSaddlePath = solveInfo.ExitFlag==0 | isinf(solveInfo.ExitFlag);

while true
    ix = solveInfo.ExitFlag==-4;
    if any(ix)
        body = [body, BRX, ...
            'Model declared nonlinear, fails to solve ', ...
            'because of problems with steady state %s.'];
        args{end+1} = exception.Base.alt2str(ix);
        hereMarkAsProcessed( );
        continue
    end
    
    ix = solveInfo.ExitFlag==-2;
    if any(ix)
        body = [body, BRX, ...
            'Singularity or linear dependency in some equations %s'];
        args{end+1} = exception.Base.alt2str(ix);
        hereMarkAsProcessed( );
        continue
    end
    
    ix = solveInfo.ExitFlag==0;
    if any(ix)
        body = [body, BRX, 'No stable solution %s'];
        args{end+1} = exception.Base.alt2str(ix);
        hereMarkAsProcessed( );
        continue
    end
    
    ix = isinf(solveInfo.ExitFlag);
    if any(ix)
        body = [body, BRX, 'Multiple stable solutions %s'];
        args{end+1} = exception.Base.alt2str(ix);
        hereMarkAsProcessed( );
        continue
    end
    
    ix = imag(solveInfo.ExitFlag)~=0;
    if any(ix)
        body = [body, BRX, 'Complex derivatives %s'];
        args{end+1} = exception.Base.alt2str(ix);
        hereMarkAsProcessed( );
        continue
    end
    
    ix = isnan(solveInfo.ExitFlag);
    if any(ix)
        body = [body, BRX, 'NaNs in system matrices %s'];
        args{end+1} = exception.Base.alt2str(ix);
        hereMarkAsProcessed( );
        continue
    end
    
    % Singularity in state space or steady state problem
    ix = solveInfo.ExitFlag==-1;
    if any(ix)
        if any(solveInfo.Singularity(:))
            pos = find(any(solveInfo.Singularity, 2));
            pos = pos(:).';
            for ieq = pos
                body = [body, BRX, ...
                    'Singularity or NaN in this measurement equation %s: %s'];
                args{end+1} = exception.Base.alt2str(solveInfo.Singularity(ieq, :));
                args{end+1} = this.Equation.Input{ieq};
            end
        elseif ~this.IsLinear && isnan(this, 'sstate')
            body = [body, BRX, ...
                'Model is declared nonlinear but some steady states are NaN', ...
                ];
            args{end+1} = exception.Base.alt2str(ix);
        else
            body = [body, BRX, ...
                'Singularity in state-space matrices %s'];
            args{end+1} = exception.Base.alt2str(ix);
        end
        hereMarkAsProcessed( );        
        continue
    end
    
    ix = solveInfo.ExitFlag==-3;
    if any(ix)
        args = { };
        for ii = find(ix)
            for jj = find(solveInfo.InxNanDeriv{ii})
                body = [body, BRX, ...
                    'NaN in derivatives of this equation %s: %s'];
                args{end+1} = exception.Base.alt2str(ii);
                args{end+1} = this.Equation.Input{jj};
            end
        end
        hereMarkAsProcessed( );
        continue
    end
    
    break
end

if any(inxReportSaddlePath)
    body = [body, BRX, ...
        '[Bkw variables, Unit roots, Stable roots]: ', ...
        sprintf( ...
        [ exception.Base.ALT2STR_DEFAULT_LABEL, '#%g[%g %g %g] ' ], ...
        [ find(inxReportSaddlePath); solveInfo.SaddlePath(:, inxReportSaddlePath) ] ...
        ) ];
end

return

    function hereMarkAsProcessed( )
        solveInfo.ExitFlag(ix) = 1;
    end%
end%
