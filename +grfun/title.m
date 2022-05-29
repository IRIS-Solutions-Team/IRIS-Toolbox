function TT = title(varargin)
% title  [Not a public function] Advanced graph titles and subtitles.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if all(ishghandle(varargin{1}))
    Ax = varargin{1};
    varargin(1) = [ ];
else
    Ax = gca( );
end

TT = [ ];
if isempty(varargin)
    return
end

text = varargin{1};
varargin(1) = [ ];


defaults = { 
    'interpreter', 'latex', @(x) ischar(x) && any(strcmpi(x, {'latex', 'tex', 'none'}))
};

[opt,varargin] = passvalopt(defaults, varargin{:});


%--------------------------------------------------------------------------

% Add title to the current subplot.
% * Double backslash, \\, is line breaks.
% * Double underscore, __, is subtitles.
match = regexp(strrep(text,'__',char(10)),'[^\n]+','match');

if isempty(match)
    tmpTitle = '';
    tmpSubtitle = '';
elseif length(match) == 1
    tmpTitle = strtrim(match{1});
    tmpSubtitle = '';
else
    tmpTitle = strtrim(match{1});
    tmpSubtitle = strtrim(match{end});
end

tmpTitle = strrep(tmpTitle,'//',char(10));
tmpTitle = strrep(tmpTitle,'\\',char(10));
tmpTitle = regexp(tmpTitle,'[^\n]+','match');
tmpTitle = tmpTitle(:);

% Display subtitles in italic if the option `interpreter=` is set to `tex`
% or `latex`; otherwise the command `\it` would be displayed literally.
if ~isempty(tmpSubtitle)
    if any(strcmpi(opt.interpreter,{'latex','tex'}))
        tmpTitle{end+1} = ['\it{',tmpSubtitle,'}'];
    else
        tmpTitle{end+1} = tmpSubtitle;
    end
end

if ~isempty(tmpTitle)
    TT = title(Ax,tmpTitle,'interpreter',opt.interpreter, ...
        varargin{:});
end

end
