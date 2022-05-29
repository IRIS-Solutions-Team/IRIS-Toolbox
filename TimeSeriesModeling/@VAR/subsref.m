function varargout = subsref(This,S)
% subsref  Subscripted reference for VAR objects.
%
% Syntax to retrieve VAR object with subset of parameterisations
% ===============================================================
%
%     V(Inx)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% * `Inx` [ numeric | logical ] - Index of requested parameterisations.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if any(strcmp(S(1).type,{'()','{}'})) ...
        && length(S(1).subs) == 1
    nalt = length(This);
    if ischar(S(1).subs) && strcmp(S(1).subs{1},':');
        inx = 1 : nalt;
    else
        inx = S(1).subs{1};
    end
    This = subsalt(This,inx);
    if length(S) == 1
        varargout{1} = This;
    else
        [varargout{1:nargout}] = subsref(This,S(2:end));
    end
else
    [varargout{1:nargout}] = builtin('subsref',This,S);
end

end
