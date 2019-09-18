function outputDatabank = createOutputDatabank(this, inputDatabank, extendedRange, plain, fitted, opt)
% createOutputDatabank  Create output databank from LinearRegression
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

array = plain;
names = [this.ExplanatoryNamesInDatabank, this.ErrorNamesInDatabank];
if ~isempty(fitted)
    array = [array; fitted];
    names = [names, this.FittedNamesInDatabank];
end
comments = names;
inxToInclude = @all;
timeSeriesConstructor = @default;

outputDatabank = databank.backend.fromDoubleArrayNoFrills ...
    ( array, ...
      names, ...
      extendedRange(1), ...
      comments, ...
      inxToInclude, ...
      timeSeriesConstructor, ...
      opt.OutputType, ...
      opt.AddToDatabank );

outputDatabank = appendData(this, inputDatabank, outputDatabank, extendedRange, opt);

end%

