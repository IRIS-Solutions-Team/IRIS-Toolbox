
function varargout = x12(this, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    ip.addRequired('InputSeries', @(x) isa(x, 'Series'));
    ip.addOptional('Range', Inf, @validate.range);

    ip.addParameter({'Backcast', 'Backcasts'}, 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    ip.addParameter({'CleanUp', 'DeleteTempFiles', 'DeleteTempFile', 'DeleteX12Files', 'DeleteX12File', 'Delete'}, true, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('Dummy', [ ], @(x) isempty(x) || isa(x, 'Series'));
    ip.addParameter('DummyType', 'Holiday', @(x) ischar(x) && any(strcmpi(x, {'Holiday', 'TD', 'AO'})));
    ip.addParameter('Display', false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter({'Forecast', 'Forecasts'}, 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    ip.addParameter('Log', false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('MaxIter', 1500, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>0);
    ip.addParameter('MaxOrder', [2, 1], @(x) isnumeric(x) && length(x)==2 && any(x(1)==[1, 2, 3, 4]) && any(x(2)==[1, 2]));
    ip.addParameter({'AllowMissing', 'Missing'}, false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('Mode', 'auto', @(x) (isnumeric(x) && any(x==(-1 : 3))) || any(strcmp(x, {'add', 'a', 'mult', 'm', 'auto', 'sign', 'pseudo', 'pseudoadd', 'p', 'log', 'logadd', 'l'})));
    ip.addParameter('Output', 'd11', @(x) ischar(x) || iscellstr(x));
    ip.addParameter('SaveAs', '', @ischar);
    ip.addParameter('SpecFile', 'default', @validate.stringScalar);
    ip.addParameter({'TDays', 'TDay'}, false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('TempDir', '.', @(x) ischar(x) || isa(x, 'function_handle'));
    ip.addParameter('Tolerance', 1e-5, @(x) isnumeric(x) && isscalar(x) && x>0);
    ip.addParameter('Executable', @auto, @(x) isequal(x, @auto) || strcmpi(x, 'x12awin.exe'));
end
ip.parse(this, varargin{:});
range = double(ip.Results.Range);
opt = ip.Options;


    if strcmp(opt.Mode, 'sign')
        opt.Mode = 'auto';
    end

    outputRequest( );
    numOutputs = length(opt.Output);
    co = comment(this);
    sizeData = size(this.Data);
    checkFrequency(this, range);

    [data, ~, ~, range] = getDataFromTo(this, range);

    data = data(:, :);

    % Extended range with backcasts and forecasts.
    if ~isempty(range)
        startDate = range(1);
        xStartDate = startDate - opt.Backcast;
        xRange = xStartDate : range(end)+opt.Forecast;
    else
        startDate = NaN;
        xStartDate = NaN;
        xRange = range;
    end

    % Fill in zeros for NaNs in dummy variables on the extended range.
    dummy = [ ];
    if ~isempty(opt.Dummy) && isa(opt.Dummy, 'Series')
        dummy = getData(opt.Dummy, xRange);
        dummy = dummy(:, :);
        checkDummy( );
    end

    if opt.Log
        data = log(data);
    end

    % __Run Backend X13__
    [y, Outp, Logbk, Err, Mdl] = series.x13Legacy(data, startDate, dummy, opt);

    % Convert output data to time series
    for i = 1 : numOutputs
        if opt.Log
            Outp{i} = exp(Outp{i});
        end
        Outp{i} = reshape(Outp{i}, [size(Outp{i}, 1), sizeData(2:end)]);
        Outp{i} = replace(this, Outp{i}, startDate, co);
    end

    % Reshape the model spec struct to match the dimensions and size of input
    % and output time series
    if length(sizeData)>2
        Mdl = reshape(Mdl, [1, sizeData(2:end)]);
    end

    % Return input time series with forecasts and backcasts
    numExtendedPeriods = size(y, 1);
    this.Start = xStartDate;
    this.Data = y;
    if numel(sizeData)>2
        this.Data = reshape(this.Data, [numExtendedPeriods, sizeData(2:end)]);
    end
    this = trim(this);

    % Combine all output arguments
    varargout = [ Outp, {Logbk, Err, Mdl, this} ];

return


    function outputRequest( )
        subs = struct( );
        subs.d10 = 'sf|seasonals|seasonal|seasfactors|seasfact';
        subs.d11 = 'sa|seasadj';
        subs.d12 = 'tc|trend|trendcycle';
        subs.d13 = 'ir|irregular';
        subs.mv = 'missing|missingvaladj';

        opt.Output = lower(opt.Output);
        list = fieldnames(subs);
        for ii = 1 : length(list)
            repl = list{ii};
            patt = ['\<(', subs.(repl), ')\>'];
            opt.Output = regexprep(opt.Output, patt, repl);
        end
        opt.Output = strtrim(opt.Output);
        % Handle comma-separated char lists.
        if ischar(opt.Output)
            opt.Output = regexp(opt.Output, '\w+', 'match');
        end
    end


    function checkDummy( )
        dummyIn = dummy(opt.Backcast+1:end-opt.Forecast, :);
        dummyFcast = dummy(end-opt.Forecast+1:end, :);
        dummyBcast = dummy(1:opt.Backcast, :);
        if any(isnan(dummyIn(:)))
            utils.warning('Series:x12', ...
                ['Dummy variable(s) contain(s) in-sample ', ...
                'missing observations or NaNs. ', ...
                'The NaNs will be replaced with zeros.']);
        end
        if any(isnan(dummyFcast(:)))
            utils.warning('Series:x12', ...
                ['Dummy variable(s) contain(s) missing observations or NaNs ', ...
                'on the forecast range. The NaNs will be replaced with zeros.']);
        end
        if any(isnan(dummyBcast(:)))
            utils.warning('Series:x12', ...
                ['Dummy variable(s) contain(s) missing observations or NaNs ', ...
                'on the backcast range. The NaNs will be replaced with zeros.']);
        end
        dummy(isnan(dummy)) = 0;
    end
end

