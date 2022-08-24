function [answ, isValid, query] = implementGet(this, query, varargin)

answ = [ ];
isValid = true;

if strcmpi(query, 'Incidence')
    answ = this;
    answ = answ.';
    
else
    isValid = false;
end

end
