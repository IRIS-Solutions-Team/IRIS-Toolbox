function s = vectorize(s)
% vectorize  Replace matrix operators with elementwise operators.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

FN_REPLACE = @(v) regexprep(v, '(?<!\.)(\*|/|\\|\^)', '.$1');

%--------------------------------------------------------------------------

isCellInp = iscell(s);
if ~isCellInp
    s = {s};
end

n = numel(s);
for i = 1 : n
    if ischar(s{i})
        s{i} = feval(FN_REPLACE, s{i});
    elseif isfunc(s{i})
        c = func2str(s{i});
        c = feval(FN_REPLACE, c);
        if true % ##### MOSW
            s{i} = str2func(c);
        else
            s{i} = mosw.str2func(c); %#ok<UNRCH>
        end
    end
end

if ~isCellInp
    s = s{1};
end

end
