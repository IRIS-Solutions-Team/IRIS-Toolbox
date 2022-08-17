function this = assignNameValue(this, varargin)

if nargin==1
    return
end

%--------------------------------------------------------------------------

names = varargin(1:2:end);
values = varargin(2:2:end);
numNames = numel(names);

ell = lookup(this.Quantity, names);

inxValid = true(1, numNames);
for i = 1 : numNames
    posQty__ = ell.PosName(i);
    posStdCorr__ = ell.PosStdCorr(i);
    if ~isnan(posQty__)
        this.Variant.Values(:, posQty__, :) = values{i};
    elseif ~isnan(posStdCorr__)
        this.Variant.StdCorr(:, posStdCorr__, :) = values{i};
    else
        inxValid(i) = false;
    end
end

if any(~inxValid)
    behavior = this.Behavior.InvalidDotAssign;
    if strcmpi(behavior, 'Error')
        throw(exception.Base('Model:InvalidName', 'error'), '', names{~inxValid}); %#ok<GTARG>
    elseif strcmpi(behavior, 'Warning')
        throw(exception.Base('Model:InvalidName', 'warning'), '', names{~inxValid}); %#ok<GTARG>
    else
        % Do nothing
    end 
end

end%

