function [body, args] = solveFail(this, numOfPaths, ixNanDeriv, sing2, bk)
% solveFail  Create error/warning message when function solve fails
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%#ok<*AGROW>

BRX = sprintf('\n    ');

%--------------------------------------------------------------------------

body = 'Solution not available for some parameter variant(s)';
args = { };
ixReportBK = numOfPaths==0 | isinf(numOfPaths);

while true
    ix = numOfPaths==-4;
    if any(ix)
        body = [body, BRX, ...
            'Model declared nonlinear, fails to solve ', ...
            'because of problems with steady state %s.'];
        args{end+1} = exception.Base.alt2str(ix);
        markAsProcessed( );
        continue
    end
    
    ix = numOfPaths==-2;
    if any(ix)
        body = [body, BRX, ...
            'Singularity or linear dependency in some equations %s'];
        args{end+1} = exception.Base.alt2str(ix);
        markAsProcessed( );
        continue
    end
    
    ix = numOfPaths==0;
    if any(ix)
        body = [body, BRX, 'No stable solution %s'];
        args{end+1} = exception.Base.alt2str(ix);
        markAsProcessed( );
        continue
    end
    
    ix = isinf(numOfPaths);
    if any(ix)
        body = [body, BRX, 'Multiple stable solutions %s'];
        args{end+1} = exception.Base.alt2str(ix);
        markAsProcessed( );
        continue
    end
    
    ix = imag(numOfPaths)~=0;
    if any(ix)
        body = [body, BRX, 'Complex derivatives %s'];
        args{end+1} = exception.Base.alt2str(ix);
        markAsProcessed( );
        continue
    end
    
    ix = isnan(numOfPaths);
    if any(ix)
        body = [body, BRX, 'NaNs in system matrices %s'];
        args{end+1} = exception.Base.alt2str(ix);
        markAsProcessed( );
        continue
    end
    
    % Singularity in state space or steady state problem
    ix = numOfPaths==-1;
    if any(ix)
        if any(sing2(:))
            pos = find(any(sing2, 2));
            pos = pos(:).';
            for ieq = pos
                body = [body, BRX, ...
                    'Singularity or NaN in this measurement equation %s: %s'];
                args{end+1} = exception.Base.alt2str(sing2(ieq, :));
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
        markAsProcessed( );        
        continue
    end
    
    ix = numOfPaths==-3;
    if any(ix)
        args = { };
        for ii = find(ix)
            for jj = find(ixNanDeriv{ii})
                body = [body, BRX, ...
                    'NaN in derivatives of this equation %s: %s'];
                args{end+1} = exception.Base.alt2str(ii);
                args{end+1} = this.Equation.Input{jj};
            end
        end
        markAsProcessed( );
        continue
    end
    
    break
end

if any(ixReportBK)
    body = [body, BRX, ...
        '[Bkw variables, Unit roots, Stable roots]: ', ...
        sprintf( ...
        [ exception.Base.ALT2STR_DEFAULT_LABEL, '#%g[%g %g %g] ' ], ...
        [ find(ixReportBK);bk(:, ixReportBK) ] ...
        ) ];
end

return


    function markAsProcessed( )
        numOfPaths(ix) = 1;
    end%
end%
