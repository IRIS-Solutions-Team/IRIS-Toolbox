function inxZero = prepareZeroSteady(this, inxZero)

inxZero.Level = inxZero.Level | this.Quantity.IxLagrange;
if isfield(inxZero, 'Change')
    inxZero.Change = inxZero.Change | this.Quantity.IxLagrange;
end

end%

