function anyFixedByUser = processFixOptions(this, model, opt)

% Process Fix, FixLevel, FixChange, possible with Except

quantities = this.Model.Quantity;
numQuantities = numel(quantities.Name);
inxP = quantities.Type==4;
inxCanBeFixed = this.InxEndogenous;
namesCanBeFixed = quantities.Name(inxCanBeFixed);


for fixOption = ["Fix", "FixLevel", "FixChange"]
    temp = opt.(fixOption);
    opt.(fixOption) = double.empty(1, 0);

    if isempty(temp)
        continue
    end

    if isa(temp, 'Except')
        temp = resolve(temp, namesCanBeFixed);
    end

    if ischar(temp) || (isstring(temp) && isscalar(string))
        temp = strip(split(temp, [",", ";"]));
    end
    temp = cellstr(temp);

    % Remove empty entries and names starting with ^
    temp(startsWith(temp, "^") | strlength(temp)==0) = [];

    if isempty(temp)
        continue
    end
    
    ell = lookup(quantities, temp, 1, 2, 4);
    posToFix = ell.PosName;
    inxValid = ~isnan(posToFix);
    if any(~inxValid)
        exception.error([
            "Steady:CannotFix"
            "This is not a valid name to fix "
            "because it does not exist in the object: %s "
        ], temp{~inxValid});
    end
    opt.(fixOption) = posToFix;
end


inxFixLevel = false(1, numQuantities);
inxFixLevel(opt.Fix) = true;
inxFixLevel(opt.FixLevel) = true;

inxFixChange = false(1, numQuantities);
if this.GrowthStatus
    inxFixChange(opt.Fix) = true;
    inxFixChange(opt.FixChange) = true;
    anyFixedByUser = any(inxFixLevel) || any(inxFixChange);
else
    inxFixChange(:) = true;
    anyFixedByUser = any(inxFixLevel);
end

%
% Fix steady change of all endogenized parameters to zero
%
inxFixChange(inxP) = true;


% Fix optimal policy multipliers; the level and change of
% multipliers will be set to zero in the main loop
if isfield(opt, 'ZeroMultipliers') && opt.ZeroMultipliers
    inxFixLevel = inxFixLevel | quantities.IxLagrange;
    inxFixChange = inxFixChange | quantities.IxLagrange;
end

this.QuantitiesToFix = [find(inxFixLevel), 1i*find(inxFixChange)];
this.QuantitiesToExclude = [this.QuantitiesToExclude, this.QuantitiesToFix];

end%

