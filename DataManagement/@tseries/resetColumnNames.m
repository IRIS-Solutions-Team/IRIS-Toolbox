function this = resetColumnNames(this)
% resetColumnNames  Reset comments to empty in time series
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

sizeData = size(this.Data);
sizeComments = [1, sizeData(2:end)];
this.Comment = repmat({this.EMPTY_COMMENT}, sizeComments);

end
