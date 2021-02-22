function [answ, isValid, query] = implementGet(this, query, varargin)

TYPE = @int8; %#ok<NASGU>
answ = [ ];
isValid = true;

if strcmpi(query, 'Incidence')
    answ = this;
    answ = answ.';
    
else
    isValid = false;
end

end
