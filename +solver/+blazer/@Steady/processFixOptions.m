function processFixOptions(this, model, opt)

% Process Fix, FixLevel, FixChange, possible with Except
TYPE = @int8;

quantities = this.Model.Quantity;
numQuantities = numel(quantities.Name);
inxP = quantities.Type==TYPE(4);
inxCanBeFixed = this.InxEndogenous;
namesCanBeFixed = quantities.Name(inxCanBeFixed);
list = ["Fix", "FixLevel", "FixChange"];
for fixOption = list
    temp = opt.(fixOption);

    if isempty(temp)
        opt.(fixOption) = double.empty(1, 0);
        continue
    end

    if isa(temp, 'Except')
        temp = resolve(temp, namesCanBeFixed);
    end

    if ischar(temp) || (isstring(temp) && isscalar(string))
        temp = regexp(temp, '\w+', 'match');
        if isempty(temp)
            opt.(fixOption) = double.empty(1, 0);
            continue
        end
        temp = cellstr(temp);
    elseif isstring(temp)
        temp = cellstr(temp);
    end

    if isempty(temp)
        opt.(fixOption) = double.empty(1, 0);
        continue
    end

    ell = lookup(quantities, temp, TYPE(1), TYPE(2), TYPE(4));
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

fixLevel = false(1, numQuantities);
fixLevel(opt.Fix) = true;
fixLevel(opt.FixLevel) = true;

fixChange = false(1, numQuantities);

% Fix steady change of all endogenized parameters to zero
fixChange(inxP) = true;
if opt.Growth
    fixChange(opt.Fix) = true;
    fixChange(opt.FixChange) = true;
else
    fixChange(:) = true;
end

% Fix optimal policy multipliers; the level and change of
% multipliers will be set to zero in the main loop
if isfield(opt, 'ZeroMultipliers') && opt.ZeroMultipliers
    fixLevel = fixLevel | quantities.IxLagrange;
    fixChange = fixChange | quantities.IxLagrange;
end

this.QuantitiesToFix = [find(fixLevel), 1i*find(fixChange)];
this.QuantitiesToExclude = [this.QuantitiesToExclude, this.QuantitiesToFix];

end%

