function irisConfig = reset(options)
% iris.reset  Reset IRIS configuration options to start-up values
%
% Backend IRIS class
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

if nargin==0
    options.SeriesConstructor = @Series;
    options.CheckId = true;
end

%--------------------------------------------------------------------------

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

