function [answ, flag, query] = implementGet(this, query, varargin)
% implementGet  Implement get method for rpteq objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

[answ, flag, query] = implementGet@iris.mixin.UserDataContainer(this, query, varargin{:});
if flag
    return
end

answ = [ ];
flag = true;

switch query

    case {'filename', 'fname', 'file'}
        answ = this.FileName;

    case {'lhsnames', 'lhslist'}
        answ = this.NamesOfLhs;
        
    case {'rhsnames', 'rhslist'}
        answ = this.NamesOfRhs;
        
    case {'equation', 'equations', 'eqtn', 'eqtns'}
        answ = reshape(this.UsrEqtn, [ ], 1);
        
    case {'rhs'}
        answ = reshape(this.EqtnRhs, [ ], 1);

    case {'label', 'labels'}
        answ = reshape(this.Label, [ ], 1);
        
    otherwise
        flag = false;
        
end

end%

