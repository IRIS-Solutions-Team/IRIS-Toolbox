function [answ, flag] = implementGet(this, query, varargin)
% implementGet  Implement get method for SVAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

answ = [  ];
flag = true;

switch query
    case 'b'
        [~, answ] = getResidualComponents(this);
        
    case 'cov'
        answ = getResidualComponents(this);
        
    case 'std'
        answ = this.Std;
        
    case 'method'
        answ = this.Method;
        
    otherwise
        flag = false;
end

if ~flag
    [answ, flag] = implementGet@VAR(this, query, varargin{:});
end

end
