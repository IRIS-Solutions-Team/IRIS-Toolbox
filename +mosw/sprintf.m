function Msg = sprintf(Msg,varargin)
% sprintf  [Not a public function] Workaround for Octave's sprintf.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

Msg = sprintf(Msg,varargin{:});

if true % ##### MOSW
    % Do noting.
else
    % Remove HTML tags from `Message`.
    Msg = mosw.removehtml(Msg); %#ok<UNRCH>
end

end
