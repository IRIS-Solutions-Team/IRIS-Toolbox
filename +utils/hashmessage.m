function Body = hashmessage(Body)
% hashmessage  [Not a public function] Frequent error/warning messages.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

pos = strfind(Body,':');
if ~isempty(pos)
    pos = pos(end);
    thisClass = Body(pos+1:end);
    Body(pos:end) = '';
end

switch Body
    case '#Cannot_simulate_contributions'
        Body = [ ...
            'Cannot simulate multiple parameterisations ', ...
            'or multiple data sets ', ...
            'with option contributions=true.', ...
            ];
        
    case '#Invalid_assign'
        Body = [ ...
            'Invalid assignment to a ',thisClass,' object.', ...
            ];
        
    case '#Solution_not_available'
        Body = [ ...
            'Model solution not available for some ', ...
            'parameterization(s) %s.', ...
            ];
        
    case '#Internal'
        Body = [ ...
            'Internal IRIS error. ', ...
            'Please report this error with a copy of the screen message.', ...
            ];
    
    otherwise
        % Keep `Body` unchanged.
end

end
