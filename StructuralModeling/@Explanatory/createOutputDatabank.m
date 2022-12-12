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

    descripts = local_getDescripts(this, names);

    if isequal(opt.AddToDatabank, @auto)
        opt.AddToDatabank = inputDb;
    end

    outputDb = databank.backend.fromArrayNoFrills( ...
          array, ...
          names, ...
          dataBlock.ExtendedRange(1), ...
          descripts, ...
          inxToInclude, ...
          opt.OutputType, ...
          opt.AddToDatabank ...
    );

    outputDb = appendData(this, inputDb, outputDb, extendedRange, opt);

end%


function descripts = local_getDescripts(this, names)
    %(
    lhsNames = collectLhsNames(this);
    theseDescripts = collectDescripts(this);
    [inx, pos] = ismember(names, lhsNames);
    descripts = names;
    descripts(inx) = theseDescripts(pos(inx));
    %)
end%

