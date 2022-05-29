function varargout = getSystemMatrix(this, varargin)
% getSystemMatrix  Retrieve LinearSystem matrices by their names

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

persistent pp
if isempty(pp)
    pp = extend.InputParser('LinearSystem/getSystemMatrix');
    addRequired(pp, 'linearSystem', @(x) isa(x, 'LinearSystem'));
    addRequired(pp, 'matrixName', @(x) LinearSystem.validateSystemMatrixName(x{:}));
end
parse(pp, this, varargin);

func = @(x) this.SystemMatrices{string(x)==this.NAMES_SYSTEM_MATRICES};
varargout = cellfun(func, varargin, 'UniformOutput', false);

end%

