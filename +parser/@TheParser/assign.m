% assign  Evaluate in-file values and add them to assign database
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function quantity = assign(this, quantity)

isnumericscalar = @(x) isnumeric(x) && isscalar(x);
stringify = @(x) reshape(string(x), 1, []);

a = this.AssignedDatabank;
listInvalidNamesAssigned = string.empty(1, 0);

% Evaluate values assigned in the model code and/or in the `assign`
% database. Go backward from evaluating parameters first so that they are
% available for steady-state expressions.
for i = 1 : numel(this.AssignOrder)
    inxType = quantity.Type==this.AssignOrder(i);
    if ~any(inxType)
        continue
    end
    
    for iName = find(inxType)
        name = quantity.Name{iName};
        % If the name exists in the input database, use that value.
        if isfield(a, name)
            continue
        end
        
        s = this.AssignedString{iName};
        if isempty(s)
            continue
        end
        
        s = regexprep(s, '\<[A-Za-z]\w*\>(?![\(\.])', 'a.$0');
        s = regexprep(s, 'a.NaN', 'NaN', 'ignorecase');
        s = regexprep(s, 'a.Inf', 'Inf', 'ignorecase');
        
        try
            x = eval(s);
            if isnumeric(x) % isnumericscalar(x)
                a.(name) = x(:).';
            end
        catch %#ok<CTCH>
            a.(name) = NaN;
        end
    end
end

% Remove the declared `std_` and `corr_` parameter names from the list of names
% after values in the model file have been assigned.
inxStd = startsWith(quantity.Name, quantity.STD_PREFIX);
inxCorr = startsWith(quantity.Name, quantity.CORR_PREFIX);
inxStdCorr = (inxStd | inxCorr) & quantity.Type==4;
if any(inxStdCorr)
    listStdCorr = quantity.Name(inxStdCorr);
    quantity = remove(quantity, inxStdCorr);
    % Check if all declared std_ and corr_ names are valid
    ell = lookup(quantity, listStdCorr);
    inxValid = ~isnan(ell.PosStdCorr);
    if any(~inxValid)
        listInvalidNamesAssigned = stringify(listStdCorr(~inxValid));
    end
end

if ~isempty(listInvalidNamesAssigned)
    exception.error([
        "Parser:InvalidStdCorrAssigned"
        "This std_ or corr_ parameter refers to a nonexistent shock: %s"
    ], listInvalidNamesAssigned);
end

this.AssignedDatabank = a;

end%

