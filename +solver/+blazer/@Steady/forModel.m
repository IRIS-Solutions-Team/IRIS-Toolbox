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

%--------------------------------------------------------------------------

numEquations = countEquations(model);
this = solver.blazer.Steady(numEquations);
this.SuccessOnly = opt.SuccessOnly;
this.IsBlocks = opt.Blocks;
this.IsGrowth = opt.Growth;

prepareBlazer(model, this);

this = processLogOptions(this, opt);

if isequal(opt.Exogenize, @auto) || isequal(opt.Endogenize, @auto)
    [listExogenize, listEndogenize] = resolveAutoswap(model, "steady", opt.Exogenize, opt.Endogenize);
else
    listExogenize = opt.Exogenize;
    listEndogenize = opt.Endogenize;
end

%
% Endogenize= option
%
if ischar(listEndogenize)
    listEndogenize = regexp(listEndogenize, "\w+", "match");
elseif ~iscellstr(listEndogenize)
    listEndogenize = cellstr(listEndogenize);
end
listEndogenize = unique(listEndogenize);
if ~isempty(listEndogenize)
    outp = lookup(this.Model.Quantity, listEndogenize);
    vecEndg = outp.PosName;
    endogenize(this, vecEndg);
end

%
% Exogenize= option
%
if ischar(listExogenize)
    listExogenize = regexp(listExogenize, "\w+", "match");
elseif ~iscellstr(listExogenize)
    listExogenize = cellstr(listExogenize);
end
listExogenize = unique(listExogenize);
if ~isempty(listExogenize)
    outp = lookup(this.Model.Quantity, listExogenize);
    vecExg = outp.PosName;
    exogenize(this, vecExg);
end

%
% Fix=, FixLevel=, FixChange= options
%
processFixOptions(this, opt);

end%

