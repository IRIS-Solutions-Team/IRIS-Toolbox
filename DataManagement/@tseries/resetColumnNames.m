function this = resetColumnNames(this)
% resetColumnNames  Reset commments to empty in tseries object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

sizeData = size(this.Data);
sizeComments = [1, sizeData(2:end)];
this.Comment = repmat({char.empty(1, 0)}, sizeComments);

end
