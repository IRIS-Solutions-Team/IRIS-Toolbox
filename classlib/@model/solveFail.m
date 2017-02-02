function [body, args] = solveFail(this, nPath, ixNanDeriv, sing2, bk)
% solveFail  Create error/warning message when function solve fails.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%#ok<*AGROW>

BR = sprintf('\n    ');

%--------------------------------------------------------------------------

body = 'Solution not available for some parameterization(s)';
args = { };
ixReportBK = nPath==0 | isinf(nPath);

while true
    inx = nPath==-4;
    if any(inx)
        body = [body,BR, ...
            'Model declared nonlinear, fails to solve ', ...
            'because of problems with steady state %s.'];
        args{end+1} = exception.Base.alt2str(inx);
        markAsProcessed( );
        continue
    end
    
    inx = nPath==-2;
    if any(inx)
        body = [body,BR, ...
            'Singularity or linear dependency in some equations %s'];
        args{end+1} = exception.Base.alt2str(inx);
        markAsProcessed( );
        continue
    end
    
    inx = nPath==0;
    if any(inx)
        body = [body,BR,'No stable solution %s'];
        args{end+1} = exception.Base.alt2str(inx);
        markAsProcessed( );
        continue
    end
    
    inx = isinf(nPath);
    if any(inx)
        body = [body,BR,'Multiple stable solutions %s'];
        args{end+1} = exception.Base.alt2str(inx);
        markAsProcessed( );
        continue
    end
    
    inx = imag(nPath)~=0;
    if any(inx)
        body = [body,BR,'Complex derivatives %s'];
        args{end+1} = exception.Base.alt2str(inx);
        markAsProcessed( );
        continue
    end
    
    inx = isnan(nPath);
    if any(inx)
        body = [body,BR,'NaNs in system matrices %s'];
        args{end+1} = exception.Base.alt2str(inx);
        markAsProcessed( );
        continue
    end
    
    % Singularity in state space or steady state problem
    inx = nPath==-1;
    if any(inx)
        if any(sing2(:))
            pos = find(any(sing2,2));
            pos = pos(:).';
            for ieq = pos
                body = [body,BR, ...
                    'Singularity or NaN in this measurement equation %s: %s'];
                args{end+1} = exception.Base.alt2str(sing2(ieq,:));
                args{end+1} = this.Equation.Input{ieq};
            end
        elseif ~this.IsLinear && isnan(this,'sstate')
            body = [body,BR, ...
                'Model is declared nonlinear but has some NaNs ', ...
                'in its steady state %s'];
            args{end+1} = exception.Base.alt2str(inx);
        else
            body = [body,BR, ...
                'Singularity in state-space matrices %s'];
            args{end+1} = exception.Base.alt2str(inx);
        end
        markAsProcessed( );        
        continue
    end
    
    inx = nPath==-3;
    if any(inx)
        args = { };
        for ii = find(inx)
            for jj = find(ixNanDeriv{ii})
                body = [body,BR, ...
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
    body = [body,BR, ...
        '[Bkw variables, Unit roots, Stable roots]: ', ...
        sprintf( ...
        [exception.Base.ALT2STR_DEFAULT_LABEL,'#%g[%g %g %g] '], ...
        [find(ixReportBK);bk(:,ixReportBK)] ...
        ) ];
end

return

    function markAsProcessed( )
        nPath(inx) = 1;
    end

end
