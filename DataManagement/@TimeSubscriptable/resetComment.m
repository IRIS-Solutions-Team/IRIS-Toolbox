function this = resetComment(this)
% resetComment  Reset comments to empty in time series
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

sizeOfData = size(this.Data);
sizeOfComment = [1, sizeOfData(2:end)];
this.Comment = repmat({this.EMPTY_COMMENT}, sizeOfComment);

end%

