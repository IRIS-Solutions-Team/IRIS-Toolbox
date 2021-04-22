% Type `web Model/steady.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

function [this, flag, outputInfo] = steady(this, varargin)

steadyOptions = prepareSteady(this, varargin{:});

%--------------------------------------------------------------------------

if this.IsLinear
    [this, flag, outputInfo] = steadyLinear(this, steadyOptions, Inf);
else
    [this, flag, outputInfo] = steadyNonlinear(this, steadyOptions, Inf);
end

pos = getPosTimeTrend(this.Quantity);
this.Variant.Values(1, pos, :) = complex(0, 1);

end%

