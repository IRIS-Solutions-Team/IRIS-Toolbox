function SET = mystyleprocessor(H,Command) %#ok<STOUT>
% mystyleprocessor  Process graphics options.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% `Command` is a string that can use the following references:
%
% * `H` - handle to the currently processed graphics object;
% * `L` - handle to the corresponding legend object if `H` is an axes
% object.

%--------------------------------------------------------------------------

Command = strtrim(Command);
if strncmp(Command,'!!',2)
    Command = Command(3:end);
end

% Test for L (legend handle) in the command; if present, try to find the
% corresponding legend handle.
if ~isempty(regexp(Command,'\<L\>','once'))
    L = nan(size(H));
    for i = 1 : numel(H)
        x = getappdata(H(i), 'LegendPeerHandle');
        if ~isempty(x) && ishandle(x)
            L(i) = x;
        end
    end
end

eval(Command);

if nargout > 0
    try
        SET; %#ok<VUNUS>
    catch %#ok<CTCH>
        utils.error('grfun:mystyleprocessor', ...
            ['Style processor failed to create ', ...
            'the output variable SET: %s.'], ...
            Command);
    end
end

end
