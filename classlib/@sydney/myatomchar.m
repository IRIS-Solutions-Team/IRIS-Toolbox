function c = myatomchar(this)
% myatomchar  Print sydney atom to char string.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = this.args;
if ischar(a)
    c = a;
elseif numel(a)==1
    if a==0
        c = '0';
    else
        c = sprintf('%.16g', a);
    end
else
    c = sprintf('%.16g;', a);
    c = [ '[', c(1:end-1), ']' ];
end

end
