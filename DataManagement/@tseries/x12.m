function varargout = x12(this, varargin)
% x12  Access to X13-ARIMA-SEATS seasonal adjustment program.
%
%
% __Syntax with a Single Type of Output Requested__
%
%     [Y, OutpFile, ErrFile, Model, X] = x12(X, ...)
%     [Y, OutpFile, ErrFile, Model, X] = x12(X, Range, ...)
%
%
% __Syntax with Mutliple Types of Output Requested__
%
%     [Y1, Y2, ..., OutpFile, ErrFile, Model, X] = x12(X, Range, ...)
%
% See the option `'output='` for the types of output data available from
% X12.
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input data that will seasonally adjusted or filtered
% by the Census X12 Arima; `X` must be a quarterly or monthly time series.
%
% * `Range` [ numeric | char | `@all` ] - Date range on which the X12 will
% be run; `@all` means the entire on which the input time series is
% defined; `Range` may be omitted.
%
%
% __Output Arguments__
%
% * `Y`, `Y1`, `Y2`, ... [ tseries ] - Requested output data, by default
% only one type of output is returned, the seasonlly adjusted data; see the
% option `'output='`.
%
% * `OutpFile` [ cellstr ] - Contents of the output log files produced by
% X12; each cell contains the log file for one type of output requested.
%
% * `ErrFile` [ cellstr ] - Contents of the error files produced by X12;
% each cell contains the error file for one type of output requested.
%
% * `Model` [ struct ] - Struct array with model specifications and parameter
% estimates for each of the ARIMA models fitted; `Model` matches the size
% of `X` is 2nd and higher dimensions.
%
% * `X` [ tseries ] - Original input data with forecasts and/or backcasts
% appended if the options `'forecast='` and/or `'backcast='` are used.
%
%
% __Options__
%
% * `Backcast=0` [ numeric ] - Run a backcast based on the fitted ARIMA
% model for this number of periods back to improve on the seasonal
% adjustment; see help on the `x11` specs in the X13-ARIMA-SEATS manual.
% The backcast is included in the eutput argument `X`.
%
% * `CleanUp=true` [ `true` | `false` ] - Delete temporary X12 files when
% done; the temporary files are named `iris_x12a.*`.
%
% * `Log=false` [ `true` | `false` ] - Logarithmize the input data before, 
% and de-logarithmize the output data back after, running `x12`.
%
% * `Forecast=0` [ numeric ] - Run a forecast based on the fitted ARIMA
% model for this number of periods ahead to improve on the seasonal
% adjustment; see help on the `x11` specs in the X13-ARIMA-SEATS manual.
% The forecast is included in the output argument `X`.
%
% * `Display=false` [ `true` | `false` ] - Display X12 output messages in
% command window; if false the messages will be saved in a TXT file.
%
% * `Dummy=[ ]` [ tseries | empty ] - User dummy variable or variables (in
% case of a multivariate tseries object) used in X13-ARIMA-SEATS
% regression; the dummy variables must also include values for forecasts
% and backcasts if you request them; the type of the dummy can be specified
% in the option `DummyType=`.
%
% * `DummyType='Holiday'` [ `'AO'` | `'Holiday'` | `'TD'` ] - Type of the
% user dummy (which is specified through the option `'Dummy='`); the three
% basic types of dummies are additive outlier (`'AO'`), holiday flows
% (`'Holiday'`), and trading days (`'TD'`); see the X13-ARIMA-SEATS or
% X13-ARIMA documentation for more details (available from the U.S.Census
% Bureau website), look for the section on the REGRESSION spec, options
% 'user' and 'usertype'.
%
% * `'Mode='` [ *`'auto'`* | `'add'` | `'logadd'` | `'mult'` |
% `'pseudoadd'` | `'sign'` ] - Seasonal adjustment mode (see help on the
% `x11` specs in the X13-ARIMA-SEATS manual); `'auto'` means that series
% with only positive or only negative numbers will be adjusted in the
% `'mult'` (multiplicative) mode, while series with combined positive and
% negative numbers in the `'add'` (additive) mode.
%
% * `'MaxIter='` [ numeric | *`1500`* ] - Maximum number of iterations for
% the X12 estimation procedure. See help on the `estimation` specs in the
% X13-ARIMA-SEATS manual.
%
% * `'MaxOrder='` [ numeric | *`[2, 1]`* ] - A 1-by-2 vector with maximum
% order for the regular ARMA model (can be `1`, `2`, `3`, or `4`) and
% maximum order for the seasonal ARMA model (can be `1` or `2`). See help
% on the `automdl` specs in the X13-ARIMA-SEATS manual.
%
% * `AllowMissing=false` [ `true` | `false` ] - Allow for in-sample missing
% observations, and fill in values predicted by an estimated ARIMA process;
% if `false`, the seasonal adjustment will not run and a warning will be
% thrown.
%
% * `Output='SA'` [ char | cellstr ] - List of requested output data; the
% cellstr or comma-separated list can combine any number of the request
% specifications listed below in subsection Output request; See also help
% on the `x11` specs in the X13-ARIMA-SEATS manual.
%
%  `SaveAs=''` [ char | empty ] - Name (or a whole path) under which
%  X13-ARIMA-SEATS output files will be saved.
%
% * `SpecFile='default'` [ char ] - Name of the X13-ARIMA-SEATS spec file;
% if `'default'` the IRIS default spec file will be used, see description.
%
%  `TDays=false` [ `true` | `false` ] - Correct for the number of trading
%  days. See help on the `x11regression` specs in the X13-ARIMA-SEATS
%  manual.
%
% * `TempDir='.'` [ char | function_handle ] - Directory in which
% X13-ARIMA-SEATS temporary files will be created; if the directory does
% not exist, it will be created at the beginning and deleted at the end of
% the execution (unless `CleanUp=false`).
%
% * `Tolerance=1e-5` [ numeric ] - Convergence tolerance for the X13
% estimation procedure. See help on the `estimation` specs in the
% X13-ARIMA-SEATS manual.
%
%
% __Description__
%
% _Output Requests__
% 
% The option `Output=` can combine any number of the following requests:
%
% * `'SA'` - seasonally adjusted series;
%
% * `'SF'` - seasonal factors;
%
% * `'TC'` - trend-cycle component;
%
% * `'IR'` - irregular component;
%
% * `'MV'` - the original input series with missing values fitted by
% running an estimated ARIMA model.
%
%
% _Missing Observations_
%
% If you keep `AllowMissing=false` (this is the default for backward
% compatibility), `x12` will not run on series with in-sample missing
% observations, and a warning will be thrown.
%
% If you set `AllowMissing=true`, you allow for in-sample missing
% observations. The X13-ARIMA-SEATS program handles missing observations by
% filling in values predicted by the estimated ARIMA process. You can
% request the series with missing values filled in by including `MV` in the
% option `Output=`.
%
%
% _Spec File_
%
% The default X13-ARIMA-SEATS spec file is `+thirdparty/x12/default.spc`. You can
% create your own spec file to include options that are not available
% through the IRIS interface. You can use the following pre-defined
% placeholders letting IRIS fill in some of the information needed (check
% out the default file):
%
% * `$series_data$` is replaced with a column vector of input observations;
% * `$series_freq$` is replaced with a number representing the date
% frequency: either 4 for quarterly, or 12 for monthly (other frequencies
% are currenlty not supported by X13-ARIMA-SEATS);
% * `$series_startyear$` is replaced with the start year of the input
% series;
% * `$series_startper$` is replaced with the start quarter or month of the
% input series;
% * `$transform_function$` is replaced with `log` or `none` depending on
% the mode selected by the user;
% * `$forecast_maxlead$` is replaced with the requested number of ARIMA
% forecast periods used to extend the series before seasonal adjustment.
% * `$forecast_maxlead$` is replaced with the requested number of ARIMA
% forecast periods used to extend the series before seasonal adjustment.
% * `$tolerance$` is replaced with the requested convergence tolerance in
% the `estimation` spec.
% * `$maxiter$` is replaced with the requested maximum number of iterations
% in the `estimation` spec.
% * `$maxorder$` is replaced with two numbers separated by a blank space:
% maximum order of regular ARIMA, and maximum order of seasonal ARIMA.
% * `$x11_mode$` is replaced with the requested mode: `'add'` for additive, 
% `'mult'` for multiplicative, `'pseudoadd'` for pseudo-additive, or
% `'logadd'` for log-additive;
% * `$x12_save$` is replaced with the list of the requested output
% series: `'d10'` for seasonals, `'d11'` for final seasonally adjusted
% series, `'d12'` for trend-cycle, `'d13'` for irregular component.
%
% Two of the placeholders, `'$series_data$` and `$x12_output$`, are
% required; if they are not found in the spec file, IRIS throws an error.
%
%
% _Estimates of ARIMA Model Parameters_
%
% The ARIMA model specification, `Model`, is a struct with three fields:
%
% * `.spec` - a cell array with the first cell giving the structure of the
% non-seasonal ARIMA, and the second cell giving the
% structure of the seasonal ARIMA; both specifications follow the usual
% Box-Jenkins notation, e.g. `[0 1 1]`.
%
% * `.ar` - a numeric array with the point estimates of the AR coefficients
% (non-seasonal and seasonal).
%
% * `.ma` - a numeric array with the point estimates of the MA coefficients
% (non-seasonal and seasonal).
%
%
% _Example_
%
% Run X12 on the entire range of a time series:
%
%     xsa = x12(x);
%     xsa = x12(x, Inf);
%     xsa = x12(x, @all);
%     xsa = x12(x, get(x, 'range'));
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('tseries.x12');
    parser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    parser.addOptional('Range', Inf, @DateWrapper.validateRangeInput);
    parser.addParameter({'Backcast', 'Backcasts'}, 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    parser.addParameter({'CleanUp', 'DeleteTempFiles', 'DeleteTempFile', 'DeleteX12Files', 'DeleteX12File', 'Delete'}, true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Dummy', [ ], @(x) isempty(x) || isa(x, 'TimeSubscriptable'));
    parser.addParameter('DummyType', 'Holiday', @(x) ischar(x) && any(strcmpi(x, {'Holiday', 'TD', 'AO'})));
    parser.addParameter('Display', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'Forecast', 'Forecasts'}, 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    parser.addParameter('Log', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('MaxIter', 1500, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>0);
    parser.addParameter('MaxOrder', [2, 1], @(x) isnumeric(x) && length(x)==2 && any(x(1)==[1, 2, 3, 4]) && any(x(2)==[1, 2]));
    parser.addParameter({'AllowMissing', 'Missing'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Mode', 'auto', @(x) (isnumeric(x) && any(x==(-1 : 3))) || any(strcmp(x, {'add', 'a', 'mult', 'm', 'auto', 'sign', 'pseudo', 'pseudoadd', 'p', 'log', 'logadd', 'l'})));
    parser.addParameter('Output', 'd11', @(x) ischar(x) || iscellstr(x));
    parser.addParameter('SaveAs', '', @ischar);
    parser.addParameter('SpecFile', 'default', @validate.stringScalar);
    parser.addParameter({'TDays', 'TDay'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('TempDir', '.', @(x) ischar(x) || isa(x, 'function_handle'));
    parser.addParameter('Tolerance', 1e-5, @(x) isnumeric(x) && isscalar(x) && x>0);
    parser.addParameter('Executable', @auto, @(x) isequal(x, @auto) || strcmpi(x, 'x12awin.exe'));
end
parser.parse(this, varargin{:});
range = parser.Results.Range;
opt = parser.Options;

if strcmp(opt.Mode, 'sign')
    opt.Mode = 'auto';
end

%--------------------------------------------------------------------------

outputRequest( );
numOfOutputs = length(opt.Output);
co = comment(this);
sizeOfData = size(this.data);
checkFrequency(this, range);
[data, range] = getData(this, range);
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
if ~isempty(opt.Dummy) && isa(opt.Dummy, 'TimeSubscriptable')
    dummy = getData(opt.Dummy, xRange);
    dummy = dummy(:, :);
    checkDummy( );
end

if opt.Log
    data = log(data);
end

% __Run Backend X13__
[y, Outp, Logbk, Err, Mdl] = numeric.x13(data, startDate, dummy, opt);

% Convert output data to time series
for i = 1 : numOfOutputs
    if opt.Log
        Outp{i} = exp(Outp{i});
    end
    Outp{i} = reshape(Outp{i}, [size(Outp{i}, 1), sizeOfData(2:end)]);
    Outp{i} = replace(this, Outp{i}, startDate, co);
end

% Reshape the model spec struct to match the dimensions and size of input
% and output time series
if length(sizeOfData)>2
    Mdl = reshape(Mdl, [1, sizeOfData(2:end)]);
end

% Return input time series with forecasts and backcasts
numOfExtendedPeriods = size(y, 1);
this.Start = xStartDate;
this.Data = y;
if numel(sizeOfData)>2
    this.Data = reshape(this.Data, [numOfExtendedPeriods, sizeOfData(2:end)]);
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
            utils.warning('tseries:x12', ...
                ['Dummy variable(s) contain(s) in-sample ', ...
                'missing observations or NaNs. ', ...
                'The NaNs will be replaced with zeros.']);
        end
        if any(isnan(dummyFcast(:)))
            utils.warning('tseries:x12', ...
                ['Dummy variable(s) contain(s) missing observations or NaNs ', ...
                'on the forecast range. The NaNs will be replaced with zeros.']);
        end
        if any(isnan(dummyBcast(:)))
            utils.warning('tseries:x12', ...
                ['Dummy variable(s) contain(s) missing observations or NaNs ', ...
                'on the backcast range. The NaNs will be replaced with zeros.']);
        end
        dummy(isnan(dummy)) = 0;
    end
end
