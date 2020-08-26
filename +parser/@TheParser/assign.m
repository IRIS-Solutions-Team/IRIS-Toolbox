function quantity = assign(this, quantity)
% assign  [Not a public function] Evaluate in-file values and add them to assign database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = this.AssignedDatabank;
lsInvalidStdCorrAssigned = cell(1, 0);

% Evaluate values assigned in the model code and/or in the `assign`
% database. Go backward from evaluating parameters first so that they are
% available for steady-state expressions.
for i = 1 : numel(this.AssignOrder)
    ixType = quantity.Type==this.AssignOrder(i);
    if ~any(ixType)
        continue
    end
    
    for iName = find(ixType)
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

% Remove the declared `std_` and `corr_` names from the list of names
% after values in the model file have been assigned.
ixStd = startsWith(quantity.Name, quantity.STD_PREFIX);
ixCorr = startsWith(quantity.Name, quantity.CORR_PREFIX);
ixStdCorr = ixStd | ixCorr;
if any(ixStdCorr)
    % Check if all declared std_ and corr_ names are valid.
    lsStdCorr = quantity.Name(ixStdCorr);
    quantity = remove(quantity, ixStdCorr);
    ell = lookup(quantity, lsStdCorr);
    ixValid = ~isnan(ell.PosStdCorr);
    if any(~ixValid)
        lsInvalidStdCorrAssigned = lsStdCorr(~ixValid);
    end
end

if ~isempty(lsInvalidStdCorrAssigned)
    throw( exception.ParseTime('TheParser:INVALID_STD_CORR_ASSIGNED', 'error'), ...
        lsInvalidStdCorrAssigned{:} );
end

this.AssignedDatabank = a;

end
