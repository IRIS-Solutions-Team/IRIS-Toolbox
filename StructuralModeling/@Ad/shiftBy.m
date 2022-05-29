function expn = shiftBy(expn, by, ixApplyTo)
% myshift  Shift all lags and leads of variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if by==0
    return
end

ptn = '\<x(\d+)(([pm]\d+)?)\>(?!\()';
replaceFunc = @replace; %#ok<NASGU>
expn = regexprep(expn, ptn, '${ replaceFunc($0, $1, $2) }');

return


    function c = replace(c0, c1, c2)
        n = sscanf(c1, '%g', 1);
        if ~ixApplyTo(min(n, end))
            c = c0;
            return
        end
        if isempty(c2)
            oldSh = 0;
        elseif c2(1)=='p'
            oldSh = sscanf(c2(2:end), '%g', 1);
        elseif c2(1)=='m'
            oldSh = -sscanf(c2(2:end), '%g', 1);
        end
        newSh = round(oldSh + by);
        if newSh==0
            c2 = '';
        elseif newSh>0
            c2 = sprintf('p%g', newSh);
        else
            c2 = sprintf('m%g', -newSh);
        end
        c = ['x', c1, c2];
    end
end
