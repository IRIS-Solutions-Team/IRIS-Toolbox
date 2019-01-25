function vec = printSolutionVector(this, type, logStyle)
% printSolutionVector  Print vectors of variables as in solution matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

if nargin<3
    logStyle = 'log()';
end

%--------------------------------------------------------------------------

if ischar(type)
    vec = cell(1, 0);
    indexLog = false(1, 0);
    for iType = lower(type)
        switch iType
            case 'y'
                % Vector of measurement variables.
                pos = this.Vector.Solution{1};
                vec = [vec, this.Quantity.Name(pos)]; %#ok<AGROW>
                indexLog = [indexLog, this.Quantity.IxLog(pos)]; %#ok<AGROW>
            case {'x', 'xi'}
                % Vector of transition variables.
                pos = real(this.Vector.Solution{2});
                sh = imag(this.Vector.Solution{2});
                iVec = this.Quantity.Name(pos);
                for i = find(sh~=0)
                    iVec{i} = sprintf('%s{%+g}', iVec{i}, sh(i));
                end
                vec = [vec, iVec]; %#ok<AGROW>
                indexLog = [indexLog, this.Quantity.IxLog(pos)]; %#ok<AGROW>
            case 'e'
                % Vector of shocks.
                pos = this.Vector.Solution{3};
                vec = [vec, this.Quantity.Name(pos)]; %#ok<AGROW>
                indexLog = [indexLog, this.Quantity.IxLog(pos)]; %#ok<AGROW>
            case 'g'
                % Vector of exogenous variables.
                pos = this.Vector.Solution{5};
                vec = [vec, this.Quantity.Name(pos)]; %#ok<AGROW>
                indexLog = [indexLog, this.Quantity.IxLog(pos)]; %#ok<AGROW>
        end
    end
else
    pos = real(type);
    sh = imag(type);
    pos = transpose(pos(:));
    sh = transpose(sh(:));
    vec = this.Quantity.Name(pos);
    for i = find(sh~=0)
        vec{i} = sprintf('%s{%+g}', vec{i}, sh(i));
    end
    indexLog = this.Quantity.IxLog(pos);
end

% Wrap log variables
if any(indexLog)
    if isequal(logStyle, @Behavior)
        logStyle = this.Behavior.LogStyleInSolutionVectors;
    end
    switch logStyle
        case 'log()'
            vec(indexLog) = strcat('log(', vec(indexLog), ')');
        case this.LOG_PREFIX
            vec(indexLog) = strcat(this.LOG_PREFIX, vec(indexLog));
        otherwise
            % Do nothing
    end
end

end%

