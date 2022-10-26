
% >=R2019b
%{
function irisConfig = reset(opt)

arguments
    opt.Silent = false
    opt.CheckId (1, 1) logical = true
    opt.TeX (1, 1) logical = false
end
%}
% >=R2019b


% <=R2019a
%(
function irisConfig = reset(varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Silent", false);
    addParameter(ip, "CheckId", true);
    addParameter(ip, "TeX", false);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


iris.Configuration.clear();

irisConfig = iris.Configuration(opt);
save(irisConfig);

if opt.CheckId
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

