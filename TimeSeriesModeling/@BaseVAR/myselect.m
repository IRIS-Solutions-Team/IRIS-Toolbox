function [inxSelected, namesInvalid] = myselect(this, type, select)

    switch string(lower(type))
        case "y"
            list = this.EndogenousNames;
        case "e"
            list = this.ResidualNames;
    end

    numEndogenous = this.NumEndogenous;
    select = reshape(select, 1, []);
    namesInvalid = cell.empty(1, 0);

    if isequal(select, Inf) || isequal(select, @all)
        inxSelected = true(1, numEndogenous);
    elseif isnumeric(select)
        inxSelected = false(1, numEndogenous);
        inxSelected(select) = true;
    elseif iscellstr(select) || ischar(select) || isstring(select)
        if ischar(select)
            select = regexp(select, '\w+', 'match');
        end
        select = reshape(cellstr(select), 1, []);
        inxSelected = ismember(list, select);
        inxValid = ismember(select, list);
        if any(~inxValid)
            namesInvalid = select(~inxValid);
        end
    elseif islogical(select)
        inxSelected = reshape(select, 1, []);
    else
        inxSelected = false(1, numEndogenous);
    end

    if numel(inxSelected)>numEndogenous
        inxSelected = inxSelected(1:numEndogenous);
    elseif numel(inxSelected)<numEndogenous
        inxSelected(end+1:numEndogenous) = false;
    end

end%

