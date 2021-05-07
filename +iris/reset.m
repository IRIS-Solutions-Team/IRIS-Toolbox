% iris.reset  Reset IRIS configuration options to start-up values
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function irisConfig = reset(options)

arguments
    options.Silent = false
    options.SeriesConstructor = @Series
    options.CheckId (1, 1) logical = true
    options.TeX (1, 1) logical = false
end
%)
% >=R2019b


% <=R2019a
%{
function irisConfig = reset(varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser("iris.reset");
    addParameter(inputParser, "Silent", false, @validate.logicalScalar);
    addParameter(inputParser, "SeriesConstructor", @Series, @(x) isa(x, "function_handle"));
    addParameter(inputParser, "CheckId", true, @validate.logicalScalar);
    addParameter(inputParser, "TeX", false, @validate.logicalScalar);
end
options = parse(inputParser, varargin{:});
%}
% <=R2019a


passvalopt( );

iris.Configuration.clear( );

irisConfig = iris.Configuration(options);
irisConfig.DefaultTimeSeriesConstructor = options.SeriesConstructor;
save(irisConfig);

if options.CheckId
    hereCheckId( );
end

return

    function hereCheckId( )
        release = irisConfig.Release;
        list = dir(fullfile(irisConfig.IrisRoot, 'iristbx*'));
        if numel(list)==1
            idFileVersion = regexp(list.name, '(?<=iristbx)\d+\-?\w+', 'match', 'once');
            if ~strcmp(release, idFileVersion)
                error( 'IrisToolbox:StartupError', ...
                       ['The [IrisToolbox] release check file (%s) does not match ', ...
                       'the current release of the [IrisToolbox] (%s). ', ...
                       'Delete everything from the [IrisToolbox] root folder, ', ...
                       'and reinstall the [IrisToolbox].'], ...
                       idFileVersion, release );
            end
        elseif isempty(list)
            error( 'IrisToolbox:StartupError', ...
                   ['The [IrisToolbox] release check file is missing. ', ...
                   'Delete everything from the [IrisToolbox] root folder, ', ...
                   'and reinstall the [IrisToolbox].'] );
        else
            error( 'IrisToolbox:StartupError', ...
                   ['There are mutliple [IrisToolbox] release check files ', ...
                   'found in the [IrisToolbox] root folder. This is because ', ...
                   'you installed a new [IrisToolbox] in a folder with an old ', ...
                   'release, without deleting the old release first. ', ...
                   'Delete everything from the [IrisToolbox] root folder, ', ...
                   'and reinstall [IrisToolbox].'] );
        end
    end%
end%

