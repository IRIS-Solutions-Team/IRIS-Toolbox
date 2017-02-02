function idoc(varargin)
% idoc  Display IRIS help in Web browser/Matlab documentation window.
%
% Syntax
% =======
%
%      idoc
%      idoc object_name
%      idoc package_name
%      idoc object_name/function_name
%      idoc package_name/function_name
%
%
% Example
% ========
%
%     idoc model
%     idoc model/acf
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    path = 'Contents';
    title = 'index';
else
    varargin{1} = strrep(varargin{1},'.','/');
    [path,title] = fileparts(varargin{1});
    if isempty(path) && ~isempty(title)
        path = title;
        title = 'Contents';
    end
end

filePath = fullfile(irisroot( ),'^help',path,[title,'.html']);
if isempty(path) || isempty(title) || exist(filePath,'file')~=2
    filePath = fullfile(irisroot( ),'^help','Contents','index.html');
end
web(filePath);

end
