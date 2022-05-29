% hashmessage  Frequent error/warning messages
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function body = hashmessage(body)

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
            'with option Contributions=true.', ...
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
            'Internal IrisT error. ', ...
            'Please report this error with a copy of the screen message.', ...
            ];
    
    otherwise
        % Do nothing.
end

end%

