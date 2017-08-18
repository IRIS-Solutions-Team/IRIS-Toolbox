function x = pct(x, varargin)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('TimeSeries/pct');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'TimeSeries'));
    INPUT_PARSER.addOptional('Shift', -1, @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer'}));
    INPUT_PARSER.addOptional('Order', 1, @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', '>=', 0}));
end

INPUT_PARSER.parse(x, varargin{:});
shift = INPUT_PARSER.Results.Shift;
order = INPUT_PARSER.Results.Order;

%--------------------------------------------------------------------------

if isnad(x.Start)
    return
end

x.Data = TimeSeries.shiftedDataFun(x.Data, @(x, y) 100*(x-y)./y, shift, order);
x = trim(x);

end
