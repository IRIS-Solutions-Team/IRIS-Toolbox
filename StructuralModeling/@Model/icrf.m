%{
% 
% # `icrf` ^^(Model)^^
% 
% {== Initial-condition response functions, first-order solution only ==}
% 
% 
%  ## Syntax ##
% 
%      S = icrf(M, NPer, ...)
%      S = icrf(M, Range, ...)
% 
% 
%  ## Input Arguments ##
% 
%  `M` [ model ] 
% >
% > Model object for which the initial condition responses
% > will be simulated.
% >
% 
%  `Range` [ numeric | char ]
% >
% > Date range with the first date being the
% > shock date.
% >
% 
%  `NPer` [ numeric ] 
% >
% > Number of periods.
% >
% 
%  ## Output Arguments ##
% 
%  `S` [ struct ]
% >
% > Databank with initial condition response series.
% >
% 
%  ## Options ##
% 
%  `'Delog='` [ *`true`| `false` ] 
% >
% > Delogarithmise the responses for
% > variables declared as `!log_variables`.
% >
% 
%  `'Size='` [ numeric | *`1`for linear models | *`log(1.01)`for non-linear
%  models ] 
% > 
% > Size of the deviation in initial conditions.
% >
% 
%  ## Description ##
% >
% > Function `icrf` returns the responses of all model variables to a
% > deviation (of a given size) in one initial condition. All other
% > initial conditions remain undisturbed and all shocks remain zero in the
% > simulation.
% >
% 
% ## Examples
% 
%}
% --8<--


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

