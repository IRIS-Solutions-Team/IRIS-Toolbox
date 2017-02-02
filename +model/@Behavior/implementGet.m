function [answ, isValid, query] = implementGet(this, query, varargin)

answ = [ ];
isValid = true;

switch upper(query)
    case 'BEHAVIOR'
        answ = this;
        
    otherwise
        isValid = false;
end

end
