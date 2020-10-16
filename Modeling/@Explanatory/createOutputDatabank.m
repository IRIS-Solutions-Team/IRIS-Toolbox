% createOutputDatabank  Create output databank from Explanatory
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function outputDatabank = createOutputDatabank( ...
    this, inputDatabank, dataBlock, namesToInclude, fitted, lhsTransform, opt ...
)

if isempty(namesToInclude) && isempty(fitted) && isempty(lhsTransform)
    return
end

extendedRange = dataBlock.ExtendedRange;
array = dataBlock.YXEPG;
names = dataBlock.Names;
inxToInclude = ismember(names, namesToInclude);
if ~isempty(fitted)
    array = [array; fitted];
    names = [names, this.FittedName];
    inxToInclude = [inxToInclude, true(1, size(fitted, 1))];
end
if ~isempty(lhsTransform)
    array = [array; lhsTransform];
    names = [names, this.LhsTransformName];
    inxToInclude = [inxToInclude, true(1, size(lhsTransform, 1))];
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

