% Type `web Model/steady.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [this, flag, outputInfo] = steady(this, varargin)

    steadyRunner = prepareSteady(this, varargin{:});
    if steadyRunner.Run
        [this, flag, outputInfo] = steadyRunner.Func(this, Inf, steadyRunner.Arguments{:});
    end

end%

