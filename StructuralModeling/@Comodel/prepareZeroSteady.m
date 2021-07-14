function inxZero = prepareZeroSteady(this, inxZero)

inxZero = prepareZeroSteady@Model(this, inxZero);

numQuants = numel(this.Quantity);

%
% Costds(k)=n (n>0) if k-th name is a conditioning shocks, and n is the
% respective costd
%
inxAdd = false(1, numQuants);
inxAdd(this.Pairing.Costds>0) = true;

inxZero.Level = inxZero.Level | inxAdd;
if isfield(inxZero, 'Change')
    inxZero.Change = inxZero.Change | inxAdd;
end

end%

