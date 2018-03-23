function [trend, cycle] = hpf(this, varargin)
% hpf  Hodrick-Prescott filter with conditioning information.

persistent INPUT_PARSER KALMAN TIME_SERIES

if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('TimeSeries/hpf');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'TimeSeries'));
    INPUT_PARSER.addOptional('Range', Inf, @(x) isa(x, 'Date') || isequal(x, Inf));
    INPUT_PARSER.addParameter('Lambda', @auto, @(x) isequal(x, @auto) || (isnumeric(x) && numel(x)==1 && x>0));
end

if isempty(KALMAN)
    createKalmanObject( );
end

if ~isa(TIME_SERIES, 'TimeSeries')
    TIME_SERIES = TimeSeries( );
end

INPUT_PARSER.parse(this, varargin{:});
range = INPUT_PARSER.Results.Range;
lambda = INPUT_PARSER.Results.Lambda;

if isnad(this.Start)
    return
end

%--------------------------------------------------------------------------

minRange = min(range);
maxRange = max(range);
data = getDataFromRange(this, minRange, maxRange);
sizeData = size(data);
nPer = sizeData(1);

if isequal(lambda, @auto)
    lambda = autoLambda( );
end

KALMAN.CovarianceMatrices = {diag([1, lambda]), double.empty(0)};
initialize(KALMAN);

trendData = nan(sizeData);
cycledata = nan(sizeData);
ixy0 = [ ];
for i = 1 : prod(sizeData(2:end))
    KALMAN.InputData = {data(:, i).', [ ], [ ], [ ]};
    ixy = ~isnan(data(:, i));
    if ~isequal(ixy, ixy0);
        ixy0 = ixy;
        filter(KALMAN);
    else
        fastFilter(KALMAN);
    end
    trendData(:, i) = KALMAN.Backward.StateMean(1, :).';
    cycleData(:, i) = KALMAN.Backward.StateMean(3, :).';
end

trend = fill(TIME_SERIES, trendData, this.Start);
trend = trim(trend);

cycle = fill(TIME_SERIES, cycleData, this.Start);
cycle = trim(cycle);

return




    function lambda = autoLambda( )
        periodsPerYear = getPeriodsPerYear(this.Frequency);
        displayName = getDisplayName(this.Frequency);
        assert( ...
            ~isnan(periodsPerYear), ...
            'TimeSeries:hpf', ...
            'No default lambda exists for this date frequency: %s', ...
            displayName ...
        );
        lambda = 100 * double(periodsPerYear) .^ 2;
    end




    function createKalmanObject( )
        T = [1, 1, 0; 0, 1, 0; 0, 0, 0];
        R = [1, 0; 1, 0; 0, 1];
        K = zeros(3, 0);
        Z = [1, 0, 1];
        H = zeros(1, 0);
        D = zeros(1, 0);
        U = [ ];
        KALMAN = kalman.InvariantLinear( );
        KALMAN.SystemMatrices = {T, R, K, Z, H, D, U};
        KALMAN.EigenValues = [1, 1, 0];
    end
end
