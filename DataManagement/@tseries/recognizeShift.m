function [this, subs, sh] = recognizeShift(this, subs)
% recognizeShift  Recognize lag or lead in subscripted reference, and shift
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(subs)>=1 ...
        && strcmp(subs(1).type, '{}') ...
        && length(subs(1).subs)==1 ...
        && isnumeric(subs(1).subs{1}) ...
        && ~isa(subs(1).subs{1}, 'DateWrapper') ...
        && isscalar(subs(1).subs{1}) ...
        && subs(1).subs{1}==round(subs(1).subs{1}) ...
        && isfinite(subs(1).subs{1})
    
    sh = subs(1).subs{1};
    this.start = addTo(this.start, -sh);
    subs(1) = [ ];
else
    sh = 0;
end

end
