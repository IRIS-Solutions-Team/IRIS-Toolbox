% dater.plus  Add increment to date or numeric date
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function output = plus(this, that)

output = (round(100*double(this)) + round(100*double(that))) / 100;

end%

