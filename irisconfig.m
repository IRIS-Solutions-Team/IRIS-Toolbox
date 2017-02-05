function icfg = irisconfig(varargin)
% irisconfig  Configure default values for IRIS config preferences.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

icfg = struct( );

% Factory defaults
%------------------
% Date preferences.
icfg.freq = [0, 1, 2, 4, 6, 12, 52, 365];
freqName = {
    'Unspecified'
    'Yearly'
    'Half-Yearly'
    'Quarterly'
    'Bimonthly'
    'Monthly'
    'Weekly'
    'Daily'
    };
icfg.FreqName = containers.Map(icfg.freq, freqName);
icfg.freqletters = 'YHQBMW';
icfg.dateformat = struct( ...
    'unspecified', 'P', ...
    'yy', 'YF', ...
    'hh', 'YFP', ...
    'qq', 'YFP', ...
    'bb', 'YFP', ...
    'mm', 'YFP', ...
    'ww', 'YFP', ...
    'dd', '$YYYY-Mmm-DD' );
icfg.baseyear = 2000; % Base year for deterministic time trends.
% Plot date formats for each frequency: Y, H, Q, B, M, W. Unspecified
% frequency is simply printed as a number.
icfg.plotdateformat = struct( ...
    'unspecified','P', ...    
    'yy', 'Y', ...
    'hh', 'Y:P', ...
    'qq', 'Y:P', ...
    'bb', 'Y:P', ...
    'mm', 'Y:P', ...
    'ww', 'Y:P', ...
    'dd', '$YYYY-Mmm-DD' );
icfg.months = { ...
    'January', 'February', 'March', 'April', 'May', 'June', ...
    'July', 'August', 'September', 'October', 'November', 'December'};
icfg.standinmonth = 'first';
icfg.wwday = 'Thu';

% Tseries preferences.
icfg.tseriesformat = '';
icfg.tseriesmaxwspace = 5;

% Locate TeX binary engines.
% [Config.PdfLaTeXPath, folder] = findtexmf('xelatex');
% if isempty(Config.PdfLaTeXPath)
    [icfg.PdfLaTeXPath, folder] = findTexMf('pdflatex');
% end
icfg.epstopdfpath = locateFile('epstopdf', folder);

% Empty user data.
icfg.userdata = [ ];

% Execute the user configuration file
%-------------------------------------
if utils.exist('irisuserconfig.m', 'file')
    icfg = irisuserconfig(icfg);
    icfg.userconfigpath = which('irisuserconfig.m');
else
    icfg.userconfigpath = '';
end

% Validate
%----------
% Validate the required options in case the user have modified their
% values.
validateConfig( );

list = fieldnames(icfg.validate);
invalid = { };
missing = { };
for i = 1 : numel(list)
    if isfield(icfg,list{i})
        validFn = icfg.validate.(list{i});
        value = icfg.(list{i});
        if ~validFn(value)
            invalid{end+1} = list{i}; %#ok<AGROW>
        end
    else
        missing{end+1} = list{i}; %#ok<AGROW>
    end
end

% Report the options that have been assigned invalid values.
if ~isempty(invalid)
    x = struct( );
    x.message = sprintf(...
        ['\n*** IRIS cannot start because the value supplied ', ...
        'for this IRIS config option is invalid: ''%s''.'], ...
        invalid{:});
    x.identifier = 'iris:config';
    x.stack = dbstack( );
    x.stack = x.stack(end);
    error(x);
end

% Report the options that are missing (=have been removed by the user).
if ~isempty(missing)
    x = struct( );
    x.message = sprintf(...
        ['\n*** IRIS cannot start because this IRIS option is ', ...
        'missing from IRIS config struct: ''%s''.'], ...
        missing{:});
    x.identifier = 'iris:config';
    x.stack = dbstack( );
    x.stack = x.stack(end);
    error(x);
end

% Options that cannot be customised
%-----------------------------------
% IRIS root folder.
icfg.irisroot = fileparts(which('irisstartup.m'));

% Read IRIS version. The IRIS version is stored in the root Contents.m
% file, and is displayed by the Matlab ver( ) command.
x = ver( );
ix = strcmp('IRIS Macroeconomic Modeling Toolbox', {x.Name});
if any(ix)
    if sum(ix)>1
        disp(' ');
        error('IRIS:Fatal', [ ...
            'Cannot start IRIS up properly ', ...
            'because there are conflicting IRIS root folders or versions on the Matlab path. ', ...
            'Remove *ALL* IRIS versions and folders from the Matlab path, ', ...
            'and try again.', ...
            ]);
    end
    icfg.version = regexp(x(ix).Version, '\d+\-?\w+', 'match', 'once');
else
    utils.warning('config:irisconfig', ...
        'Cannot determine the current version of IRIS.');
    icfg.version = '???';
end

% User cannot change these properties.
icfg.protected = { 
    'freq'
    'FreqName'
    'userconfigpath'
    'irisroot'
    'version'
    'validate'
    'protected'
    };

return

    
    
    
    function validateConfig( )
        nFreq = numel(icfg.freq);
        dateStructFields = ...
            {'yy','hh','qq','bb','mm','ww','dd','unspecified'};
        dateFormatStructValidFn = @(X) isstruct(X) && length(X) == 1 ...
            && all(isfield(X,dateStructFields));
        icfg.validate = struct( ...
            'FreqName', ...
            @(x) isa(x, 'containers.Map') && length(x)==nFreq && strcmp(x.KeyType, 'double') && strcmp(x.ValueType, 'char'), ...
            'freqletters', ...
            @(x) ( ischar(x) && numel(x)==numel(unique(x)) ...
            && numel(x)==nFreq-2 ) ...
            || isequal(x,@config), ...
            'dateformat', ...
            @(x) isequal(x, @config) || isequal(x, @excel) || ischar(x) || iscellstr(x) ...
            || dateFormatStructValidFn(x), ...
            'plotdateformat', ...
            @(x) isequal(x,@config) || ischar(x) || iscellstr(x) ...
            || dateFormatStructValidFn(x), ...
            'baseyear',@(x) isnumeric(x) && length(x)==1 && x==round(x), ...
            'months',@(x) (iscellstr(x) && numel(x)==12) ...
            || isequal(x,@config), ...
            'standinmonth',@(x) (isnumeric(x) && numel(x)==1 && x>0) ...
            || isequal(x,'first') || isequal(x,'last') ...
            || isequal(x,@config), ...
            'wwday', ...
            @(x) any(strcmpi(x,{'Mon','Tue','Wed','Thu','Fri','Sat','Sun'})), ...
            'tseriesformat',@ischar, ...
            'tseriesmaxwspace', ...
            @(x) isnumeric(x) && length(x)==1 && x==round(x) && x>0, ...
            'PdfLaTeXPath',@ischar, ...
            'epstopdfpath',@ischar ...
            );
    end
end




function fPath = locateFile(file, folder)
try, folder; catch, folder = ''; end %#ok<NOCOM,VUNUS,CTCH>

if ~isempty(folder)
    if ispc( )
        list = dir(fullfile(folder, [file, '.exe']));
    else
        list = dir(fullfile(folder, file));
    end
else
    list = [ ];
end

if length(list)==1
    fPath = fullfile(folder, list.name);
else
    fPath = findTexMf(file);
end
end




function [path, folder] = findTexMf(file)
% Try FINDTEXMF first.
[flag, path] = system(['findtexmf --file-type=exe ', file]);
% If FINDTEXMF fails, try to run WHICH on Unix platforms.
if flag~=0 && isunix( )
    % Unix, macOS
    [flag, path] = tryFolder('/usr/texbin', file);
    if flag~=0
        [flag, path] = tryFolder('/Library/TeX/texbin', file);
        if flag~=0
            [flag, path] = system(['which ', file]);
        end
    end
end
if flag==0
    % Use the correctly spelled path and the right file separators.
    path = strtrim(path);
    [folder, ttl, ext] = fileparts(path);
    path = fullfile(folder, [ttl, ext]);
else
    path = '';
    folder = '';
end
end




function [flag, path] = tryFolder(folder, file)
x = dir(fullfile(folder, file));
if length(x)==1
    flag = 0;
    path = fullfile(folder, file);
else
    flag = -1;
    path = '';
end
end
