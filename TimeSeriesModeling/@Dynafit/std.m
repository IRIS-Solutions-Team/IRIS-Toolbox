% std
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function outputDb = mean(this)

outputDb = struct();
names = this.ObservedNames;
for i = 1 : numel(names)
    try
        outputDb.(names(i)) = this.Std(i);
    catch
        outputDb.(names(i)) = NaN;
    end
end

end%

