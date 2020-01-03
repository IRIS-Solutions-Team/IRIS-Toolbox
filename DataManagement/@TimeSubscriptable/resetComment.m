function this = resetComment(this)
% resetComment  Reset time series comments to empty 
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

sizeOfData = size(this.Data);
this.Comment = repmat( {this.EMPTY_COMMENT}, ...
                       [1, sizeOfData(2:end)] );

end%

