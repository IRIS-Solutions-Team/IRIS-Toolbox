% forModel  Static constructor of solver.blazer.Steady for @Model objects
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function this = forModel(model, opt)

if isequal(opt.Growth, @auto)
    opt.Growth = hasGrowth(model);
end

numEquations = countEquations(model);
this = solver.blazer.Steady(numEquations);
this.SuccessOnly = opt.SuccessOnly;
this.IsBlocks = opt.Blocks;
this.IsGrowth = opt.Growth;

prepareBlazer(model, this);

this = processLogOptions(this, opt);

if isequal(opt.Exogenize, @auto) || isequal(opt.Endogenize, @auto)
    [namesToExogenize, namesToEndogenize] = resolveAutoswap(model, "steady", opt.Exogenize, opt.Endogenize);
else
    namesToExogenize = opt.Exogenize;
    namesToEndogenize = opt.Endogenize;
end

%
% Process the Endogenize option
%
if ischar(namesToEndogenize)
    namesToEndogenize = regexp(namesToEndogenize, "\w+", "match");
elseif ~iscellstr(namesToEndogenize)
    namesToEndogenize = cellstr(namesToEndogenize);
end
namesToEndogenize = unique(namesToEndogenize);
if ~isempty(namesToEndogenize)
    endogenize(this, namesToEndogenize);
end

%
% Process the Exogenize option
%
if ischar(namesToExogenize)
    namesToExogenize = regexp(namesToExogenize, "\w+", "match");
elseif ~iscellstr(namesToExogenize)
    namesToExogenize = cellstr(namesToExogenize);
end
namesToExogenize = unique(namesToExogenize);
if ~isempty(namesToExogenize)
    exogenize(this, namesToExogenize);
end

%
% Process the Fix, FixLevel, FixChange options
%
processFixOptions(this, model, opt);

end%

