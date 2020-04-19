function outputDatabank = createOutputDatabank(this, inputDatabank, dataBlock, namesToInclude, fitted, opt)
% createOutputDatabank  Create output databank from Explanatory
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

if isempty(namesToInclude) && isempty(fitted)
    return
end

extendedRange = dataBlock.ExtendedRange;
array = dataBlock.YXEPG;
names = dataBlock.Names;
inxToInclude = ismember(names, namesToInclude);
if ~isempty(fitted)
    array = [array; fitted];
    names = [names, this.FittedName];
    numFitted = size(fitted, 1);
    inxToInclude = [inxToInclude, true(1, numFitted)];
end
comments = names;
timeSeriesConstructor = @default;

if isequal(opt.AddToDatabank, @auto)
    opt.AddToDatabank = inputDatabank;
end

outputDatabank = databank.backend.fromDoubleArrayNoFrills( ...
      array, ...
      names, ...
      dataBlock.ExtendedRange(1), ...
      comments, ...
      inxToInclude, ...
      timeSeriesConstructor, ...
      opt.OutputType, ...
      opt.AddToDatabank ...
);

outputDatabank = appendData(this, inputDatabank, outputDatabank, extendedRange, opt);

end%

