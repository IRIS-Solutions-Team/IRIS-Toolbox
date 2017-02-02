function [ix, lsInvalid] = myselect(this, type, select)
% myselect  [Not a public function] Convert user name selection to a logical index.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

switch lower(type)
    case 'y'
        list = myynames(this);
    case 'e'
        list = myenames(this);
end

N = length(this.YNames);
select = select(:).';
lsInvalid = { };

if isequal(select,Inf)
    ix = true(1,N);
elseif isnumeric(select)
    ix = false(1,N);
    ix(select) = true;
elseif iscellstr(select) || ischar(select)
    if ischar(select)
        select = regexp(select,'\w+','match');
    end
    ix = false(1,N);
    nSelect = length(select);
    for i = 1 : nSelect
        cmp = strcmp(list,select{i});
        if any(cmp)
            ix = ix | cmp;
        else
            lsInvalid{end+1} = select{i}; %#ok<AGROW>
        end
    end
elseif islogical(select)
    ix = select;
else
    ix = false(1,N);
end

ix = ix(:).';

if length(ix) > N
    ix = ix(1:N);
elseif length(ix) < N
    ix(end+1:N) = false;
end

end