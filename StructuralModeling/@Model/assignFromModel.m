%{
% 
% # `assignFromModel` ^^(Model)^^
% 
% {== Assign model quantities from another model ==}
% 
% 
% ## Syntax 
% 
%     m = assignFromModel(m, n)
% 
% 
% ## Input arguments 
% 
% __`m`__ [ Model ]
% > 
% > Model object that will be assigned values from `n`.
% > 
% 
% __`n`__ [ Model ]
% > 
% > Model object from which values will be assigned to `m`.
% > 
% 
% 
% ## Output arguments 
% 
% __`m`__ [ Model ]
% > 
% > Model object with the new values assigned
% > 
% 
% 
% ## Description 
% 
% 
% ## Examples
% 
% ```matlab
% ```
% 
%}
% --8<--


% >=R2019b
%{
function [this, namesAssigned] = assignFromModel(this, that, opt)

arguments
    this Model
    that Model

    opt.Names (1, :) = @all
    opt.CrossType (1, 1) logical = false
    opt.Level (1, 1) logical = true
    opt.Change (1, 1) logical = true
    opt.ClonePattern (1, 2) string = ["", ""]
end
%}
% >=R2019b


% <=R2019a
%(
function [this, namesAssigned] = assignFromModel(this, that, varargin)

persistent ip
if isempty(ip)
    addParameter(ip, "Names", @all);
    addParameter(ip, "CrossType", false);
    addParameter(ip, "Level", true);
    addParameter(ip, "Change", true);
    addParameter(ip, "ClonePattern", ["", ""]);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
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


nvRhs = countVariants(that);
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

rhsNames = textual.stringify(that.Quantity.Name);
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

    if that.Quantity.Type(inxRhs)~=this.Quantity.Type(inxThis)
        crossType(end+1) = n;
        if ~opt.CrossType
            continue
        end
    end

    oldValue = this.Variant.Values(1, inxThis, :);
    rhsValue = that.Variant.Values(1, inxRhs, :);
    type = this.Quantity.Type(1, inxThis);
    isLog = this.Quantity.InxLog(1, inxThis);
    newValue = local_createNewValue(oldValue, rhsValue, type, isLog, opt);
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
    listStdCorrRhs = [ getStdNames(that.Quantity), getCorrNames(that.Quantity) ];
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

        this.Variant.StdCorr(1, inxThis, :) = real(that.Variant.StdCorr(1, inxRhs, :));
        assigned(end+1) = n;
    end
end

end%

%
% Local functions
%

function newValue = local_createNewValue(oldValue, rhsValue, type, isLog, opt)
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

