% forModel  Static constructor of solver.blazer.Steady for @Model objects
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = forModel(model, opt)

if isequal(opt.Growth, @auto)
    opt.Growth = hasGrowth(model);
end

numEquations = countEquations(model);
this = solver.blazer.Steady(numEquations);
this.SuccessOnly = opt.SuccessOnly;
this.GrowthStatus = opt.Growth;
if isempty(opt.SaveAs)
    opt.SaveAs = "";
end
this.SaveAs = string(opt.SaveAs);

prepareBlazer(model, this);




this = processLogOptions(this, opt);

opt.Exogenize = local_preprocessSwaps(opt.Exogenize);
opt.Endogenize = local_preprocessSwaps(opt.Endogenize);

if isequal(opt.Exogenize, @auto) || isequal(opt.Endogenize, @auto)
    [namesToExogenize, namesToEndogenize] = resolveAutoswap(model, "steady", opt.Exogenize, opt.Endogenize);
else
    namesToExogenize = opt.Exogenize;
    namesToEndogenize = opt.Endogenize;
end

%
% Process the Endogenize option
%
namesToEndogenize = unique(cellstr(namesToEndogenize));
if ~isempty(namesToEndogenize)
    endogenize(this, namesToEndogenize);
end

%
% Process the Exogenize option
%
namesToExogenize = unique(cellstr(namesToExogenize));
if ~isempty(namesToExogenize)
    exogenize(this, namesToExogenize);
end

anyFixedByUser = processFixOptions(this, model, opt);

%
% Resolve opt.BLocks=@auto; fixed are quantities specified by the user
%
if isequal(opt.Blocks, @auto)
    opt.Blocks = ~anyFixedByUser;
end
this.IsBlocks = opt.Blocks;

end%

%
% Local functions
%

function list = local_preprocessSwaps(list)
    %(
    if ~validate.text(list)
        return
    end
    list = string(list);
    if isempty(list)
        return
    end
    if isscalar(list)
        list = regexp(list, "\^?\w+", "match");
    end
    list = strip(list);
    list(startsWith(list, "^")) = [];
    list = unique(reshape(list, 1, []));
    %)
end%

