function [s, range, select] = icrf(this, time, varargin)

DEFAULT_LOG_DEVIATION = log(1.01);

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.icrf');
    parser.addRequired('SolvedModel', @validate.solvedModel);
    parser.addRequired('Time', @(x) isnumeric(x) || isa(x, 'DateWrapper')); 
    parser.addParameter('Delog', true, @validate.logicalScalar);
    % TODO: Introduce Select= option
    % parser.addParameter('Select', @all, @(x) ~isempty(x) && (isequal(x, @all) || validate.list(x)));
    parser.addParameter('Size', @auto, @(x) isequal(x, @auto) || validate.numericScalar(x));
end
parse(parser, this, time, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

[~, ~, numOfBwl, numOfFwl] = sizeSolution(this.Vector);
inxOfInit = this.Variant.InxOfInit;
numOfInit = nnz(inxOfInit);

% Set the size of the initial conditions
if isequal(opt.Size, @auto)
    % Default 1 for linearized, log(1.01) for log-linearized
    sizeOfDeviation = ones(1, numOfInit);
    inxOfLog = this.Quantity.InxLog;
    if any(inxOfLog)
        realId = real(this.Vector.Solution{2}(numOfFwl+1:end));
        realId = realId(inxOfInit);
        inxOfLogInit = inxOfLog(realId);
        sizeOfDeviation(inxOfLogInit) = DEFAULT_LOG_DEVIATION;
    end
else
    % User supplied
    sizeOfDeviation = opt.Size;
    if isscalar(sizeOfDeviation)
        sizeOfDeviation = repmat(sizeOfDeviation, 1, numOfBwl);
    end
end

select = get(this, 'InitCond');
select = regexprep(select, 'log\((.*?)\)', '$1', 'once');

func = @(T, R, K, Z, H, D, U, Omg, ~, numOfPeriods) ...
       timedom.icrf( T, [ ], [ ], Z, [ ], [ ], U, [ ], ...
                     numOfPeriods, sizeOfDeviation, inxOfInit );

[s, range] = responseFunction(this, time, func, select, opt);

end%

