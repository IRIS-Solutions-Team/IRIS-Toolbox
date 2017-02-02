function s = altersubs(s,n,obj)
% altersubs  [Not a public function] Check and re-organise subscripted reference to objects with mutliple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% This function accepts the following subscripts
%     x(index)
%     x.name
%     x.(index)
%     x.name(index)
%     x(index).name(index)
% where index is either logical or numeric or ':'
% and returns
%     x(numeric)
%     x.name(numeric)

% Convert x(index1).name(index2) to x.name(index1(index2)).
if length(s) == 3 && any(strcmp(s(1).type,{'()','{}'})) ...
        && strcmp(s(2).type,{'.'}) ...
        && any(strcmp(s(3).type,{'()','{}'}))
    % convert a(index1).name(index2) to a.name(index1(index2))
    index1 = s(1).subs{1};
    if strcmp(index1,':')
        index1 = 1 : n;
    end
    index2 = s(3).subs{1};
    if strcmp(index2,':');
        index2 = 1 : length(index1);
    end
    s(1) = [ ];
    s(2).subs{1} = index1(index2);
end

% Convert a(index).name to a.name(index).
if length(s) == 2 && any(strcmp(s(1).type,{'()','{}'})) ...
        && strcmp(s(2).type,{'.'})
    s = s([2,1]);
end

if length(s) > 2
    utils.error('utils:altersubs', ...
        ['Invalid reference to ',obj object.']);
end

% Convert a(:) or a.name(:) to a(1:n) or a.name(1:n).
% Convert a(logical) or a.name(logical) to a(numeric) or a.name(numeric).
if any(strcmp(s(end).type,{'()','{}'}))
    if strcmp(s(end).subs{1},':')
        s(end).subs{1} = 1 : n;
    elseif islogical(s(end).subs{1})
        s(end).subs{1} = find(s(end).subs{1});
    end
end

% Throw error for mutliple indices
% a(index1,index2,...) or a.name(index1,index2,...).
if any(strcmp(s(end).type,{'()','{}'}))
    if length(s(end).subs) ~= 1 || ~isnumeric(s(end).subs{1})
        utils.error(obj,['Invalid reference to ',obj,' object.']);
    end
end

% Throw error if index is not real positive integer.
if any(strcmp(s(end).type,{'()','{}'}))
    index = s(end).subs{1};
    if any(index < 1) || any(round(index) ~= index) ...
            || any(imag(index) ~= 0)
        utils.error(obj, ...
            ['Subscript indices must be ', ...
            'either real positive integers or logicals.']);
    end
end

end
