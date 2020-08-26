function outputDb = fromDoubleArray(array, names, startDate, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('+databank/fromDoubleArray');

    addRequired(pp, 'array', @(x) isnumeric(x) && ndims(x)==2);
    addRequired(pp, 'names', @(x) isstring(x) || ischar(x) || iscellstr(x));
    addRequired(pp, 'startDate', @DateWrapper.validateProperDateInput);

    addParameter(pp, 'Comments', [ ], @(x) isempty(x) || isstring(x) || ischar(x) || iscellstr(x));
    addParameter(pp, 'OutputType', @auto, @(x) isequal(x, @auto) || validate.anyString(x, 'struct', 'Dictionary'));
    addParameter(pp, 'AddToDatabank', false, @(x) isempty(x) || isequal(x, false) || validate.databank(x));
end
%)
opt = parse(pp, array, names, startDate, varargin{:});

%--------------------------------------------------------------------------

outputDb = databank.backend.fromDoubleArrayNoFrills( ...
    permute(array, [2, 1, 3:ndims(array)]) , names, startDate ...
    , opt.Comments, @all, @default, opt.OutputType, opt.AddToDatabank ...
);

end%
