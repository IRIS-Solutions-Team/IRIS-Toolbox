function vec = printSolutionVector(this, type)
% printSolutionVector  Print vectors of variables as in solution matrices.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(type)
    vec = cell(1, 0);
    ixLog = false(1, 0);
    for iType = lower(type)
        switch iType
            case 'y'
                % Vector of measurement variables.
                pos = this.Vector.Solution{1};
                vec = [vec, this.Quantity.Name(pos)]; %#ok<AGROW>
                ixLog = [ixLog, this.Quantity.IxLog(pos)]; %#ok<AGROW>
            case 'x'
                % Vector of transition variables.
                pos = real(this.Vector.Solution{2});
                sh = imag(this.Vector.Solution{2});
                iVec = this.Quantity.Name(pos);
                for i = find(sh~=0)
                    iVec{i} = sprintf('%s{%g}', iVec{i}, sh(i));
                end
                vec = [vec, iVec]; %#ok<AGROW>
                ixLog = [ixLog, this.Quantity.IxLog(pos)]; %#ok<AGROW>
            case 'e'
                % Vector of shocks.
                pos = this.Vector.Solution{3};
                vec = [vec, this.Quantity.Name(pos)]; %#ok<AGROW>
                ixLog = [ixLog, this.Quantity.IxLog(pos)]; %#ok<AGROW>
            case 'g'
                % Vector of exogenous variables.
                pos = this.Vector.Solution{5};
                vec = [vec, this.Quantity.Name(pos)]; %#ok<AGROW>
                ixLog = [ixLog, this.Quantity.IxLog(pos)]; %#ok<AGROW>
        end
    end
else
    pos = real(type);
    sh = imag(type);
    vec = this.Quantity.Name(pos);
    for i = find(sh~=0)
        vec{i} = sprintf('%s{%g}', vec{i}, sh(i));
    end
    ixLog = this.Quantity.IxLog(pos);
end

% Wrap log variables.
if any(ixLog)
    vec(ixLog) = strcat('log(', vec(ixLog), ')');
end

end
