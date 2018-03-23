function [answ, flag, query] = implementGet(this, query, varargin)
% implementGet  Implement get method for rpteq objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

[answ, flag, query] = implementGet@shared.UserDataContainer(this, query, varargin{:});
if flag
    return
end

answ = [ ];
flag = true;

switch query

    case {'filename', 'fname', 'file'}
        answ = this.FileName;

    case {'lhsnames', 'lhslist'}
        answ = this.NameLhs;
        
    case {'rhsnames', 'rhslist'}
        answ = this.NameRhs;
        
    case {'equation', 'equations', 'eqtn', 'eqtns'}
        answ = this.UsrEqtn;
        
    case {'rhs'}
        answ = this.EqtnRhs;

    case {'label', 'labels'}
        answ = this.Label;
        
    otherwise
        flag = false;
        
end

end
