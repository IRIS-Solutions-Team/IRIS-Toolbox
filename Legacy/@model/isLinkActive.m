function varargout = isLinkActive(this, list)
% isLinkActive  True if dynamic link is active
%{
% Syntax
%--------------------------------------------------------------------------
%
%
%     flag = isLinkActive(model, list)
%     db = isLinkActive(model)
%
%
% Input arguments
%--------------------------------------------------------------------------
%
%
% __`model`__ [ Model ] 
% Model object whose dynamic links, i.e. `[!links](irislang/links)`, will
% be queried.
%
%
% __`list`__ [ char | cellstr | string ] 
% > List of LHS names whose dynamic links will be (re)activated.
%
%
% Output arguments
%--------------------------------------------------------------------------
%
%
% __`flag`__ [ logical ] 
% > Logical array with the status (`true` means active, `false` means
% inactive) for each LHS name from the `list`.
%
%
% __`db`__ [ struct ] 
% > Database with the status (`true` means active, `false` means inactive)
% for each LHS name in dynamic links.
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

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
    varargout{1} = cell2struct(num2cell(flag), this.Quantity.Name(lhsPtr), 2);
end

end%
