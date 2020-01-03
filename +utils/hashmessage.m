function body = hashmessage(body)
% hashmessage  Frequent error/warning messages.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

pos = strfind(body,':');
if ~isempty(pos)
    pos = pos(end);
    thisClass = body(pos+1:end);
    body(pos:end) = '';
end

switch body
    case '#Cannot_simulate_contributions'
        body = [ ...
            'Cannot simulate multiple parameter variants ', ...
            'or multiple data sets ', ...
            'with option contributions=true.', ...
            ];
        
    case '#Invalid_assign'
        body = [ ...
            'Invalid assignment to a ',thisClass,' object.', ...
            ];
        
    case '#Solution_not_available'
        body = [ ...
            'Model solution not available for some ', ...
            'parameter variant(s) %s.', ...
            ];
        
    case '#Internal'
        body = [ ...
            'Internal IRIS error. ', ...
            'Please report this error with a copy of the screen message.', ...
            ];
    
    otherwise
        % Do nothing.
end

end
