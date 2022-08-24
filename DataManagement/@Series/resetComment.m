% resetComment  Reset time series comments to empty 
%
% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function this = resetComment(this)

sizeData = size(this.Data);
this.Comment = strings([1, sizeData(2:end)]);

end%

