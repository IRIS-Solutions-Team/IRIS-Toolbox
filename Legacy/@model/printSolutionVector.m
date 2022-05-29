% printSolutionVector  Print vectors of variables as in solution matrices
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function output = printSolutionVector(this, vec, varargin)

if ~isempty(varargin) && isequal(varargin{1}, @Behavior)
    varargin{1} = this.Behavior.LogStyleInSolutionVectors;
end

%--------------------------------------------------------------------------

if ischar(vec) || isstring(vec)
    type = string(vec);
    vec = [ ];
    if any(contains(type, "y", "IgnoreCase", true))
        vec = [vec, reshape(this.Vector.Solution{1}, 1, [ ])];
    end
    if any(contains(type, "x", "IgnoreCase", true))
        vec = [vec, reshape(this.Vector.Solution{2}, 1, [ ])];
    end
    if any(contains(type, "e", "IgnoreCase", true))
        vec = [vec, reshape(this.Vector.Solution{3}, 1, [ ])];
    end
    if any(contains(type, "g", "IgnoreCase", true))
        vec = [vec, reshape(this.Vector.Solution{5}, 1, [ ])];
    end
end

output = printVector(this.Quantity, vec, varargin{:});
output = reshape(cellstr(output), 1, [ ]);

end%

