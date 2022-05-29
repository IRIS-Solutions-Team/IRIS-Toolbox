% forModel  Static constructor of solver.blazer.Stacked for @Model objects
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = forModel(model, opt)

numEquations = countEquations(model);
this = solver.blazer.Stacked(numEquations);
this.SuccessOnly = opt.SuccessOnly;
this.IsBlocks = opt.Blocks;
this.StartIterationsFrom = opt.StartIterationsFrom;
this.Terminal = opt.Terminal;

prepareBlazer(model, this);

this = processLogOptions(this, opt);

end%

