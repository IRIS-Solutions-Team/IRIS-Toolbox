function C = ellipsis(C,N)
% ellipsis  Trim long strings and add ellipsis.
%
% Syntax
% =======
%
%     C = ellipsis(C,N)
%
% Input arguments
% ================
%
% * `C` [ char | cellstr ] - Input string or cell array of strings that
% will be trimmed.
%
% * `N` [ numeric ] - Maximum length of the output string.
%
% Output arguments
% =================
%
% * `C` [ char | cellstr ] - Strings cut to the maximum length `N`; all
% longer strings have an ellipsis (...) inserted at the end.
%
% Description
% ============
%
% Example
% ========
%
%     C = 'This is a string longer than 20 characters.';
%     textfun.ellipsis(C,20)
%     ans =
%     This is a string ...
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if iscellstr(C)
    for i = 1 : numel(C)
        C{i} = textfun.ellipsis(C{i},N);
    end
    return
end

%--------------------------------------------------------------------------

if length(C) > N
    C = [C(1:N-3),'...'];
end
C = sprintf('%-*s',N,C);

end
