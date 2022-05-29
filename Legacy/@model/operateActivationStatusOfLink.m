function varargout = operateActivationStatusOfLink(this, newStatus, list)
% operateActivationStatusOfLink  Activate or deactivate dynamic links
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('Model/operateActivationStatusOfLink');
    addRequired(pp, 'model', @(x) isa(x, 'model'));
    addRequired(pp, 'newStatus', @(x) validate.numericScalar(x) && any(x==[0, -1, 1]));
    addRequired(pp, 'list', @(x) ischar(x) || iscellstr(x) || isa(x, 'string') || isequal(x, @all));
end
parse(pp, this, newStatus, list);
list = pp.Results.list;

%--------------------------------------------------------------------------

if isequal(list, @all)
    lhsPtr = @all;
else
    list = cellstr(list);
    ell = lookup(this.Quantity, list);
    lhsPtr = ell.PosName;
end

if newStatus==0
    [posLink, inxValid, lhsPtr] = lookup(this.Link, lhsPtr);
    if any(~inxValid)
        hereThrowInvalidName( );
    end
    varargout = {this.Link.InxActive(posLink), lhsPtr};
else
    [this.Link, inxValid] = changeActivationStatus(this.Link, lhsPtr, newStatus);
    if any(~inxValid)
        hereThrowInvalidName( );
    end
    varargout{1} = this;
end

return

    function hereThrowInvalidName( )
        thisError = [
            "Link:InvalidLHSName"
            "This is not a valid LHS name in dynamic links: %s "
        ];
        throw(exception.Base(thisError, 'error'), list{~inxValid});
    end%
end%

