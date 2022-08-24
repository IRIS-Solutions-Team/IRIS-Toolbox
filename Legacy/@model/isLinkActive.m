function varargout = isLinkActive(this, list)

    if nargin>=2
        convertToDatabank = false;
    else
        convertToDatabank = true;
        list = @all;
    end

    [flag, lhsPtr] = operateActivationStatusOfLink(this, 0, list);

    if ~convertToDatabank
        varargout{1} = flag;
    else
        varargout{1} = cell2struct(num2cell(flag), cellstr(this.Quantity.Name(lhsPtr)), 2);
    end

end%

