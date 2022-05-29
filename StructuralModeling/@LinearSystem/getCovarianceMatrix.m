function varargout = getCovarianceMatrix(this, varargin)
% getCovarianceMatrix  Retrieve LinearSystem matrices by their names

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

persistent pp
if isempty(pp)
    pp = extend.InputParser('LinearSystem/getCovarianceMatrix');
    addRequired(pp, 'linearSystem', @(x) isa(x, 'LinearSystem'));
    addRequired(pp, 'matrixName', @(x) LinearSystem.validateCovarianceMatrixName(x{:}));
end
parse(pp, this, varargin);

func = @(x) this.CovarianceMatrices{string(x)==this.NAMES_COVARIANCE_MATRICES};
varargout = cellfun(func, varargin, 'UniformOutput', false);

end%

