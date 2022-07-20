% x13  Matlab interface for X13-ARIMA-Seats
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [Y, Outp, Logbk, Err, arimaModel] = x13Legacy(inputData, startDate, dummy, opt)

switch lower(opt.Mode)
    case {0, 'mult', 'm'}
        opt.Mode = 'mult';
    case {1, 'add', 'a'}
        opt.Mode = 'add';
    case {2, 'pseudo', 'pseudoadd', 'p'}
        opt.Mode = 'pseudoadd';
    case {3, 'log', 'logadd', 'l'}
        opt.Mode = 'logadd';
    otherwise
        opt.Mode = 'auto';
end

if ischar(opt.Output)
    opt.Output = { opt.Output };
elseif ~iscellstr(opt.Output)
    opt.Output = { 'd11' };
end
numOfOutputs = length(opt.Output);

% Get the entire path to this file.
x13Dir = fullfile(iris.root( ), '+thirdparty', 'x13');
if strcmpi(opt.SpecFile, 'default')
    opt.SpecFile = fullfile(x13Dir, 'default.spc');
end

%--------------------------------------------------------------------------

kb = opt.Backcast;
kf = opt.Forecast;
nPer = size(inputData, 1);
nx = size(inputData, 2);
startDate = double(startDate);
freq = dater.getFrequency(startDate);

% __Preallocate output arguments__
% Input data with backcast and forecast appended
Y = nan(nPer+kb+kf, nx);
% Output data
Outp = cell(1, numOfOutputs);
Outp(:) = { nan(nPer, nx) };
% Logbook
Logbk = cell(1, nx);
Logbk(:) = {''};
% Error messages
Err = cell(1, nx);
Err(:) = {''};
% ARIMA Model
arimaModel = struct( );
arimaModel.Mode = NaN;
arimaModel.Spec = [ ];
arimaModel.AR = [ ];
arimaModel.MA = [ ];
arimaModel = repmat(arimaModel, 1, nx);

if isnan(freq)
    utils.warning('thirdparty:x13:x13', ...
        'Input tseries is empty, cannot run X13.');    
    return
elseif freq~=4 && freq~=12
    utils.warning('thirdparty:x13:x13', ...
        'X13 runs only on quarterly or monthly data.');
    return
end

tempDir = opt.TempDir;
isNewTempDir = false;
doTempDir( );

is3YearsWarn = false;
is70YearsWarn = false;
is15YearsBcastWarn = false;
isNanWarn = false;
for i = 1 : nx
    tmpTitle = tempname(tempDir);
    first = find(~isnan(inputData(:, i)), 1);
    last = find(~isnan(inputData(:, i)), 1, 'last');
    data = inputData(first:last, i);
    iErrMsg = '';
    if length(data)<3*freq
        is3YearsWarn = true;
    elseif length(data)>70*freq
        is70YearsWarn = true;
    elseif ~opt.AllowMissing && any(isnan(data))
        isNanWarn = true;
    else
        if length(data)>15*freq && kb>0
            is15YearsBcastWarn = true;
        end
        offset = first - 1;
        [iOutp, fcast, bcast, ok] = ...
            runX13(x13Dir, tmpTitle, data, startDate+offset, dummy, opt);
        for j = 1 : numOfOutputs
            Outp{j}(first:last, i) = iOutp(:, j);
        end
        % Append forecasts and backcasts to original data.
        Y(first:last+kb+kf, i) = [bcast;data;fcast];
        % Catch output file.
        if exist([tmpTitle, '.out'], 'file')==2
            Logbk{i} = xxReadOutpFile([tmpTitle, '.out']);
        end
        % Catch error file.
        if exist([tmpTitle, '.err'], 'file')==2
            Err{i} = xxReadOutpFile([tmpTitle, '.err']);
            iErrMsg = regexp(Err{i}, '(?<=ERROR:).*', 'match', 'once');
            iErrMsg = regexprep(iErrMsg, '[\r\n]+', '\n');
            iErrMsg = regexprep(iErrMsg, '[ \t]+', ' ');
            iErrMsg = regexprep(iErrMsg, '\n[ \t\n]+', '\n');
        end
        % Catch ARIMA model specification.
        if exist([tmpTitle, '.mdl'], 'file')
            arimaModel(i) = readModel(arimaModel(i), [tmpTitle, '.mdl'], Logbk{i});
        end
        % Delete all X13 files.
        if ~isempty(opt.SaveAs)
            doSaveAs( );
        end
        if opt.CleanUp
            % Java delete does not work with wildcards.
            delete([tmpTitle, '.*']);
            if ismac( ) && exist('fort.6', 'file')
                delete('fort.6');
            end
        end
        if ~ok
            utils.warning('x13:x13', ...
                ['Unable to read at least on the X13 output file(s). ', ...
                'The most likely cause is ', ...
                'that X13 failed to estimate an appropriate ', ...
                'seasonal model or failed to ', ...
                'converge. Run X13 with three output arguments ', ...
                'to capture the X13 output and error messages.\n\n', ...
                'X13 says:%s'], ...
                iErrMsg);
        end
    end
end

doWarn( );

% Clean up newly created directory.
if isNewTempDir && opt.CleanUp
    rmdir(tempDir, 's');
end

return


    function doWarn( )
        if is3YearsWarn
            utils.warning('x13:x13', ...
                'X13 requires three or more years of observations.');
        end
        if is70YearsWarn
            utils.warning('x13:x13', ...
                'X13 cannot handle more than 70 years of observations.');
        end
        if is15YearsBcastWarn
            utils.warning('x13:x13', ...
                'X13 does not produce backcasts for time series longer than 15 years.');
        end
        if isNanWarn
            utils.warning('x13:x13', ...
                ['Input data contain in-sample NaNs. ', ...
                'To allow for in-sample NaNs, ', ...
                'use the option Missing=true.']);
        end
    end%


    function doSaveAs( )
        [fPath, fTitle] = fileparts(opt.SaveAs);
        list = dir([tmpTitle, '.*']);
        for ii = 1 : length(list)
            [~, ~, fExt] = fileparts(list(ii).name);
            copyfile(list(ii).name, fullfile(fPath, [fTitle, fExt]));
        end
    end%


    function doTempDir( )
        if isa(tempDir, 'function_handle')
            tempDir = tempDir( );
        end
        isNewTempDir = exist(tempDir, 'dir')==0;
        if isNewTempDir
            mkdir(tempDir);
        end
        returnDir = pwd( );
        cd(tempDir);
        tempDir = pwd( );
        cd(returnDir);
    end% 
end%


function [Data, Fcast, Bcast, Ok] = runX13(x13Dir, fileTitle, Data, startDate, dummy, opt)
    Fcast = zeros(0, 1);
    Bcast = zeros(0, 1);

    % Flip sign if all values are negative
    % so that multiplicative mode is possible.
    flipSign = false;
    if all(Data<0)
        Data = -Data;
        flipSign = true;
    end

    nonPositive = any(Data <= 0);
    if strcmp(opt.Mode, 'auto')
        if nonPositive
            opt.Mode = 'add';
        else
            opt.Mode = 'mult';
        end
    elseif strcmp(opt.Mode, 'mult') && nonPositive
        utils.warning('x13:x13', ...
            ['Unable to use multiplicative mode because of ', ...
            'input data combine positive and non-positive numbers; ', ...
            'switching to additive mode.']);
        opt.Mode = 'add';
    end

    % Write a spec file.
    locallyWriteSpecFile(fileTitle, Data, startDate, dummy, opt);

    % Set up a system command to run the X13 executable, enclosing the command in
    % double quotes.
    if isequal(opt.Executable, @auto)
        if ispc( )
            executableName = 'x13aswin.exe';
        elseif ismac( )
            executableName = 'x13asmac';
        elseif isunix( )
            executableName = 'x13asunix';
        else
            utils.error('x13:x13', ...
                ['Cannot determine your operating system ', ...
                'and choose the appropriate X13 executable.']);
        end
    else
        executableName = opt.Executable;
    end
    cmd = [ '"', fullfile(x13Dir, executableName), '"' ];

    cmd = [ cmd, ' "', fileTitle, '"' ];
    [status, result] = system(cmd);

    if opt.Display
        disp(result);
    end

    % Return NaNs if X13 fails.
    if status ~= 0
        Data(:) = NaN;
        utils.error('x13:x13', ...
            ['Unable to run the X13 executable.\n', ...
            '\tThe operating system says: %s'], ...
            result);
    end

    % Read in-sample results.
    nPer = length(Data);
    [Data, dataOk] = xxGetOutpData(fileTitle, nPer, opt.Output, 2);

    % Try to read forecasts.
    fcastOk = true;
    kf = opt.Forecast;
    if kf>0
        [Fcast, fcastOk] = xxGetOutpData(fileTitle, kf, {'fct'}, 4);
    end

    % Try to read backcasts.
    bcastOk = true;
    kb = opt.Backcast;
    if kb>0
        [Bcast, bcastOk] = xxGetOutpData(fileTitle, kb, {'bct'}, 4);
    end

    Ok = dataOk && fcastOk && bcastOk;

    if flipSign
        Data = -Data;
        Fcast = -Fcast;
        Bcast = -Bcast;
    end
end%


function locallyWriteSpecFile(fileTitle, data, startDate, dummy, opt)
    % locallyWriteSpecFile  Create and save SPC file based on a template
    [startYear, startPer] = dat2ypf(startDate);
    endDate = dater.plus(startDate, size(data, 1)-1);
    [endYear, endPer] = dat2ypf(endDate);
    [dummyYear, dummyPer] = dat2ypf(startDate-opt.Backcast);
    spec = fileread(opt.SpecFile);

    % Time series specs
    %-------------------
    % Check for the required placeholders $series_data$ and $x11_save$:
    if numel(strfind(spec, '$series_data$'))~=1 ...
            || numel(strfind(spec, '$x11_save$'))~=1
        utils.error('x13:x13', ...
            ['Invalid X13 spec file. Some of the required placeholders, ', ...
            '$series_data$ and $x11_save$, are missing or used more than once.']);
    end

    br = '\n';

    % Data
    %------
    format = '%.8f';
    cData = sprintf(['    ', format, br], data);
    cData = strrep(cData, sprintf(format, -99999), sprintf(format, -99999.01));
    cData = strrep(cData, 'NaN', '-99999');
    spec = strrep(spec, '$series_data$', cData);

    % Seasonal period specs
    %-----------------------
    freq = dater.getFrequency(startDate);
    spec = replace(spec, "$series_freq$", string(freq));
    spec = replace(spec, "$series_startyear$", string(startYear));
    spec = replace(spec, "$series_startper$", string(startPer));
    spec = replace(spec, "$series_endyear$", string(endYear));
    spec = replace(spec, "$series_endper$", string(endPer));
    if any(strcmp(opt.Output, 'mv'))
        % Save missing value adjusted series
        spec = replace(spec, "$series_missingvaladj$", "save = (mv)");
        opt.Output = setdiff(opt.Output, "mv");
    else
        spec = strrep(spec, "$series_missingvaladj$", "");
    end    

    % Transform specs
    %-----------------
    if any(strcmp(opt.Mode, {'mult', 'pseudoadd', 'logadd'}))
        spec = replace(spec, "$transform_function$", "log");
    else
        spec = replace(spec, "$transform_function$", "none");
    end

    % AUTOMDL specs
    %---------------
    spec = strrep(spec, '$maxorder$', sprintf('%g %g', round(opt.MaxOrder)));

    % FORECAST specs
    %----------------
    spec = strrep(spec, '$forecast_maxback$', sprintf('%g', opt.Backcast));
    spec = strrep(spec, '$forecast_maxlead$', sprintf('%g', opt.Forecast));

    % REGRESSION specs
    %------------------
    % If there's no REGRESSSION variable, we cannot include
    % the spec in the spec file because X13 would complain. In that case, we
    % keep the entire spec commented out. If tdays is requested but no user
    % dummies are specified, we need to keep the dummy section commented out, 
    % and vice versa.
    if opt.TDays || ~isempty(dummy)
        dummy = real(dummy);
        spec = strrep(spec, '#regression ', '');
        if opt.TDays
            spec = strrep(spec, '#tdays ', '');
            spec = strrep(spec, '$tdays$', 'td');
        end
        if ~isempty(dummy)
            spec = strrep(spec, '#dummy ', '');
            nDummy = size(dummy, 2);
            dummyFmt = [ repmat(' %.8f', 1, nDummy), br ];
            name = sprintf(' dummy%g', 1:nDummy);
            spec = strrep(spec, '$dummy_type$', lower(opt.DummyType));
            spec = strrep(spec, '$dummy_name$', name);
            spec = strrep(spec, '$dummy_data$', sprintf(dummyFmt, dummy.'));
            spec = strrep(spec, '$dummy_startyear$', ...
                sprintf('%g', round(dummyYear)));
            spec = strrep(spec, '$dummy_startper$', ...
                sprintf('%g', round(dummyPer)));
        end
    end

    % ESTIMATION specs
    spec = strrep(spec, '$maxiter$', sprintf('%g', round(opt.MaxIter)));
    spec = strrep(spec, '$tolerance$', sprintf('%e', opt.Tolerance));

    % X11 specs
    spec = strrep(spec, '$x11_mode$', opt.Mode);
    spec = strrep(spec, '$x11_save$', sprintf('%s ', opt.Output{:}));

    % Write specs to text file
    textual.write(char(spec), [fileTitle, '.spc']);
end%


function [Data, Flag] = xxGetOutpData(fileTitle, NPer, Outp, NCol)
    if ischar(Outp)
        Outp = {Outp};
    end
    Flag = true;
    Data = zeros(NPer, 0);
    format = repmat(' %f', 1, NCol);
    numOfOutputs = length(Outp);
    for i = 1 : numOfOutputs
        file = sprintf('%s.%s', fileTitle, Outp{i});
        fId = fopen(file, 'r');
        if fId>-1
            fgetl(fId); % skip first 2 lines
            fgetl(fId);
            read = fscanf(fId, format);
            fclose(fId);
        else
            read = [ ];
        end
        if length(read)==NCol*NPer
            read = reshape(read, [NCol, NPer]).';
            Data(:, end+1) = read(:, 2); %#ok<AGROW>
        else
            Data(:, end+1) = NaN; %#ok<AGROW>
            Flag = false;
        end
    end
end%


function C = xxReadOutpFile(FName)
    C = fileread(FName);
    C = textfun.removeltel(C);
    C = regexprep(C, '\n\n+', '\n\n');
end%


function arimaModel = readModel(arimaModel, FName, OuputFile)
    C = fileread(FName);

    % ARIMA spec block.
    arima = regexp(C, 'arima\s*\{\s*model\s*=([^\}]+)\}', 'once', 'tokens');
    if isempty(arima) || isempty(arima{1})
        return
    end
    arima = arima{1};

    % Non-seasonal and seasonal ARIMA model specification
    spec = regexp(arima, '\((.*?)\)\s*\((.*?)\)', 'once', 'tokens');
    if isempty(spec) || length(spec) ~= 2 ...
            || isempty(spec{1}) || isempty(spec{2})
        return
    end
    specAr = sscanf(spec{1}, '%g').';
    specMa = sscanf(spec{2}, '%g').';
    if isempty(specAr) || isempty(specMa)
        return
    end

    % Estimated AR and MA coefficients.
    estAr = regexp(arima, 'ar\s*=\s*\((.*?)\)', 'once', 'tokens');
    estMa = regexp(arima, 'ma\s*=\s*\((.*?)\)', 'once', 'tokens');
    if isempty(estAr) && isempty(estMa)
        return
    end
    try
        estAr = sscanf(estAr{1}, '%g').';
    catch %#ok<CTCH>
        estAr = [ ];
    end
    try
        estMa = sscanf(estMa{1}, '%g').';
    catch %#ok<CTCH>
        estMa = [ ];
    end
    if isempty(estAr) && isempty(estMa)
        return
    end

    mode = NaN;
    if ~isempty(OuputFile) && ischar(OuputFile)
        tok = regexp(OuputFile, 'Type of run\s*-\s*([\w\-]+)', 'tokens', 'once');
        if ~isempty(tok) && ~isempty(tok{1})
            mode = tok{1};
        end
    end

    % Create output struct only after we make sure all pieces have been read in
    % all right.
    arimaModel.Mode = mode;
    arimaModel.Spec = {specAr, specMa};
    arimaModel.AR = estAr;
    arimaModel.MA = estMa;
end%
