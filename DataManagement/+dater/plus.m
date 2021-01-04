% dater.plus  Add increment to date or numeric date
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function output = plus(this, that)

this = double(this);
that = double(that);
output = (round(100*this) + round(100*that))/100;

end%

