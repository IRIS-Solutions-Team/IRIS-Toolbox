function varargout = error(id, body, varargin)
% error  IRIS error master file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~isempty(body) && body(1)=='#'
    body = utils.hashmessage(body);
end

if true % ##### MOSW
    body = strrep(body, 'Uncle', 'Matlab');
else
    Body = strrep(Body, 'Uncle', 'Octave'); %#ok<UNRCH>
end

% Throw an error with stack of non-IRIS function calls.
stack = exception.Base.reduceStack(0);
if isempty(stack)
    stack = struct( ...
        'file', '', ...
        'name', 'command prompt', ...
        'line', NaN ...
        );
end

msg = sprintf('IRIS Toolbox Error @ %s.', id);
msg = [msg, mosw.sprintf(['\n*** ',body], varargin{:})];
msg = regexprep(msg, '(?<!\.)\.\.(?!\.)','.');

if nargout == 0
    tmp = struct( );
    tmp.message = msg;
    if ~strncmp(id, 'IRIS:', 5)
        id = ['IRIS:', id];
    end
    tmp.identifier = id;
    tmp.stack = stack;
    error(tmp);
else
    varargout{1} = msg;
end

end
