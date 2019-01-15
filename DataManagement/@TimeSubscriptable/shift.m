function this = shift(this, sh)
% shift  Shift times series by a lag or lead
%
% __Syntax__
%
%     X = shift(X, Sh)
%
%
% __Input Arguments__
%
% * `X` [ TimeSubscriptable ] - Input time series.
%
% * `Sh` [ numeric ] - Lag (a negative number) or lead (a positive number)
% by which the time series will be shifted.
%
%
% __Output Arguments__
%
% `X` [TimeSubscriptable ] - Shifted time series.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

if isscalar(sh)
    this.Start = addTo(this.Start, -sh);
    return
end

sh = sh(:).';
maxSh0 = max([sh, 0]);
minSh0 = min([sh, 0]);

sizeData = size(this.Data);
ndimsData = ndims(this.Data);
sizeTemplateData = sizeData;
sizeTemplateData(1) = sizeTemplateData(1)-minSh0+maxSh0;
templateData = nan(sizeTemplateData);
ref = cell(1, ndimsData);
ref(:) = {':'};
ref(2) = {[ ]};
newData = templateData(ref{:});
t = maxSh0 + (1 : sizeData(1));
for i = 1 : numel(sh)
    addData = templateData;
    addData(t-sh(i), :) = this.Data(:, :);
    newData = [newData, addData];
end
this.Data = newData;
this = resetComment(this);

end%

