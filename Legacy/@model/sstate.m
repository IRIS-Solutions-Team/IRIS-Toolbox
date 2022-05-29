% Legacy function
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, flag, outputInfo] = sstate(this, varargin)

steady = prepareSteady(this, varargin{:});

if this.IsLinear
    [this, flag, outputInfo] = steadyLinear(this, steady, Inf);
else
    [this, flag, outputInfo] = steadyNonlinear(this, steady, Inf);
end

end%

