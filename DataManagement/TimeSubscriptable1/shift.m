% shift  Shift times series by a lag or lead
%{
% Syntax
%--------------------------------------------------------------------------
%
%
%     outputSeries = shift(inputSeries, sh)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`inputSeries`__ [ Series ] 
%
%     Input time series that will be shifted by the lag or lead `sh`.
%
%
% __`sh`__ [ numeric ]
%
%     The lag (a negative number) or lead (a positive number) by which the
%     `inputSeries` will be shifted; see Description for what happens if
%     `sh` is a vector of numbers.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`outputSeries`__ [ Series ] 
%
%     Output time series created by shifting the `inputSeries` by a lag or
%     lead specified in `sh`.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% The `outputSeries` is created simply by changing the start date of the
% time series, shifting it by `-sh` periods.
%
% If `sh` an array of numbers, the `outputSeries` is created by
% concatenating the individual shifts along second dimension, i.e.
%
%     shift(x, sh)
%
% is the same (but more efficient) as
%
%     [shift(x, sh(1)), shift(x, sh(2)), ...]
%
%
% Example
%--------------------------------------------------------------------------
%
%
% Create a time series with two columns:
%     
%     >> x = Series(1, rand(10,2))
%     x =
%         Series Object: 10-by-2
%         Class of Data: double
%                   1          2
%                _______    _______
%         1:     0.40458    0.69627
%         2:     0.44837    0.09382
%         3:     0.36582     0.5254
%         4:      0.7635    0.53034
%         5:      0.6279    0.86114
%         6:     0.77198    0.48485
%         7:     0.93285    0.39346
%         8:     0.97274    0.67143
%         9:     0.19203    0.74126
%         10:    0.13887    0.52005
%         "Dates"    ""    ""
%         User Data: Empty
%
% Call the method `shift` with multiple lags and/or leads. The resulting
% time series is a concatenation of the individual lags and/or leads:
%
%     >> shift(x, [-1, +2])
%     ans =
%         Series Object: 13-by-4
%         Class of Data: double
%                   1          2          3          4
%                _______    _______    _______    _______
%         1:         NaN        NaN    0.40458    0.69627
%         2:         NaN        NaN    0.44837    0.09382
%         3:         NaN        NaN    0.36582     0.5254
%         4:     0.40458    0.69627     0.7635    0.53034
%         5:     0.44837    0.09382     0.6279    0.86114
%         6:     0.36582     0.5254    0.77198    0.48485
%         7:      0.7635    0.53034    0.93285    0.39346
%         8:      0.6279    0.86114    0.97274    0.67143
%         9:     0.77198    0.48485    0.19203    0.74126
%         10:    0.93285    0.39346    0.13887    0.52005
%         11:    0.97274    0.67143        NaN        NaN
%         12:    0.19203    0.74126        NaN        NaN
%         13:    0.13887    0.52005        NaN        NaN
%         "Dates"    ""    ""    ""    ""
%         User Data: Empty
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = shift(this, sh)

if isempty(this) || isempty(sh) || isequal(sh, 0)
    return
end

if isscalar(sh)
    this.Start = dater.plus(this.Start, -sh);
    return
end

sh = reshape(double(sh), 1, [ ]);
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
this = trim(this);
this = resetComment(this);

end%

