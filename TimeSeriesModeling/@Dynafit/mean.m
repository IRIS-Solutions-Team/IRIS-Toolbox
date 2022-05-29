function outputDb = mean(this)
% mean  Mean of the observables used to standardize the input data
%
% __Syntax__
%
%     x = mean(a)
%
%
% __Input Arguments__
%
% * `a` [ DFM ] - DFM object.
%
%
% __Output Arguments__
%
% * `x` [ numeric ] - Estimated mean for the vector of the DFM
% observables that has been used to destandardize the input data before
% running principal component estimation.
%
%
% __Description__
%
%
% __Example__
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

outputDb = struct();
names = this.ObservedNames;
for i = 1 : numel(names)
    try
        outputDb.(names(i)) = this.Mean(i);
    catch
        outputDb.(names(i)) = NaN;
    end
end

end%

