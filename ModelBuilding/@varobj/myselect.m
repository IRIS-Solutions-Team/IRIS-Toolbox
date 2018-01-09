function [indexSelected, namesInvalid] = myselect(this, type, select)
% myselect  Convert user name selection to logical index
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

switch lower(type)
    case 'y'
        list = this.NamesEndogenous;
    case 'e'
        list = this.NamesErrors;
end

numEndogenous = this.NumEndogenous;
select = select(:).';
namesInvalid = { };

if isequal(select, Inf) || isequal(select, @all)
    indexSelected = true(1, numEndogenous);
elseif isnumeric(select)
    indexSelected = false(1, numEndogenous);
    indexSelected(select) = true;
elseif iscellstr(select) || ischar(select)
    if ischar(select)
        select = regexp(select, '\w+', 'match');
    end
    select = select(:).';
    indexSelected = ismember(list, select);
    indexValid = ismember(select, list);
    namesInvalid = cell.empty(1, 0);
    if any(~indexValid)
        namesInvalid = select(~indexValid);
    end
elseif islogical(select)
    indexSelected = select(:).'
else
    indexSelected = false(1, numEndogenous);
end

if length(indexSelected)>numEndogenous
    indexSelected = indexSelected(1:numEndogenous);
elseif length(indexSelected)<numEndogenous
    indexSelected(end+1:numEndogenous) = false;
end

end
