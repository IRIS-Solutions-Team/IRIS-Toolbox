function [answ, isValid, query] = implementGet(this, query, varargin)

TYPE = @int8; %#ok<NASGU>
answ = [ ];
isValid = true;

if strcmpi(query, 'Gradient')
    answ = this;

else
    isValid = false;

end

end
