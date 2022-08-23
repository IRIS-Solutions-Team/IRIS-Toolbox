% createOutputDatabank  Create output databank from Explanatory
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDb = createOutputDatabank( ...
    this, inputDb, dataBlock, namesToInclude, fitted, lhsTransform, opt ...
)

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

    if isequal(opt.AddToDatabank, @auto)
        opt.AddToDatabank = inputDb;
    end

    outputDb = databank.backend.fromArrayNoFrills( ...
          array, ...
          names, ...
          dataBlock.ExtendedRange(1), ...
          comments, ...
          inxToInclude, ...
          opt.OutputType, ...
          opt.AddToDatabank ...
    );

    outputDb = appendData(this, inputDb, outputDb, extendedRange, opt);

end%

