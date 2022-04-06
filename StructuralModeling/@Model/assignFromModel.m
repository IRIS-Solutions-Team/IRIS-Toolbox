
% >=R2019b
%(
function [this, namesAssigned] = assignFromModel(this, rhs, opt)

arguments
    this Model
    rhs Model

    opt.Names (1, :) = @all
    opt.CrossType (1, 1) logical = false
    opt.Level (1, 1) logical = true
    opt.Change (1, 1) logical = true
end
%)
% >=R2019b


% <=R2019a
%{
function [this, namesAssigned] = assignFromModel(this, rhs, varargin)

persistent ip
if isempty(ip)
    addParameter(ip, "Names", @all);
    addParameter(ip, "CrossType", false);
    addParameter(ip, "Level", true);
    addParameter(ip, "Change", true);
end
parse(ip, varargin{:});
opt = ip.Results;
%}
% <=R2019a


namesAssigned = string.empty(1, 0);
clonePattern = ["", ""]; % TODO

namesToAssign = opt.Names;
if isequal(namesToAssign, @all) || isequal(namesToAssign, Inf)
    namesToAssign = [
        textual.stringify(this.Quantity.Name) ...
        , textual.stringify(getStdNames(this.Quantity)) ...
        , textual.stringify(getCorrNames(this.Quantity)) ...
    ];
end


if isempty(namesToAssign) || (~opt.Level && ~opt.Change)
    return
end


nvRhs = countVariants(rhs);
if nvRhs~=1 && nvRhs~=nv
    exception.error([
        "Model:NumVariantsMustMatch"
        "Cannot assign values between two Model objects "
        "with different numbers of alternative parameter variants."
    ]);
end

numQuantities = numel(this.Quantity);
crossType = string.empty(1, 0);
assigned = string.empty(1, 0);

rhsNames = textual.stringify(rhs.Quantity.Name);
thisNames = textual.stringify(this.Quantity.Name);
inxStdCorr = startsWith(namesToAssign, ["std_", "corr_"]);

for n = namesToAssign(~inxStdCorr)
    inxThis = n==thisNames;
    if ~any(n==namesToAssign)
        continue
    end

    inxRhs = n==rhsNames;
    if ~any(inxRhs)
        continue
    end

    if rhs.Quantity.Type(inxRhs)~=this.Quantity.Type(inxThis)
        crossType(end+1) = n;
        if ~opt.CrossType
            continue
        end
    end

    oldValue = this.Variant.Values(1, inxThis, :);
    rhsValue = rhs.Variant.Values(1, inxRhs, :);
    type = this.Quantity.Type(1, inxThis);
    isLog = this.Quantity.InxLog(1, inxThis);
    newValue = locallyCreateNewValue(oldValue, rhsValue, type, isLog, opt);
    this.Variant.Values(1, inxThis, :) = newValue;

    assigned(end+1) = n;
end


if ~isempty(crossType)
    if opt.CrossType
        func = @exception.warning;
    else
        func = @exception.error;
    end
    func([
        "Model:NameTypeMismatch"
        "This name is a different type in each of the models: %s "
    ], crossType);
end


if any(inxStdCorr)
    listStdCorrThis = [ getStdNames(this.Quantity), getCorrNames(this.Quantity) ];
    listStdCorrRhs = [ getStdNames(rhs.Quantity), getCorrNames(rhs.Quantity) ];
    listStdCorrThis = textual.stringify(listStdCorrThis);
    listStdCorrRhs = textual.stringify(listStdCorrRhs);

    for n = namesToAssign(inxStdCorr)
        inxThis = n==listStdCorrThis;
        if ~any(inxThis)
            continue
        end

        inxRhs = n==listStdCorrRhs;
        if ~any(inxRhs)
            continue
        end

        this.Variant.StdCorr(1, inxThis, :) = real(rhs.Variant.StdCorr(1, inxRhs, :));
        assigned(end+1) = n;
    end
end

end%

%
% Local functions
%

function newValue = locallyCreateNewValue(oldValue, rhsValue, type, isLog, opt)
    %(
    if type==31 || type==32
        newValue = 0;
        return
    end
    if opt.Level
        newLevel = real(rhsValue);
    else
        newLevel = real(oldValue);
    end
    if opt.Change
        newChange = imag(rhsValue);
    else
        newChange = imag(oldValue);
    end
    if isLog && newChange==0
        newChange = 1;
    end
    newValue = newLevel + 1i*newChange;
    %)
end%

