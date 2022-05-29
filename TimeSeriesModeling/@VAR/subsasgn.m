function This = subsasgn(This,S,X)
% subsasgn  Subscripted assignment for VAR objects.
%
% Syntax to assign parameterisations from other VAR object
% =========================================================
%
%     V(inx) = W
%
% Syntax to delete specified parameterisations
% =============================================
%
%     V(Inx) = [ ]
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% * `inx` [ numeric ] - Index of parameterisations that will be assigned
% or deleted.
%
% * `W` [ VAR ] - VAR object compatible with `V` whose parameterisations
% will be assigned (copied) into `V`.
%
% Output arguments
% =================
%
% * `V` [ model ] - VAR object with newly assigned or deleted
% parameterisations,
%
% Description
% ============
%
% Example
% ========
%
% Expand the number of parameterisations in a VAR object that has
% initially just one parameterisation:
%
%     V(1:10) = V;
%
% The parameterisation is simply copied ten times within the VAR object.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(S) == 1 ...
        && any(strcmp(S.type,{'()','{}'})) ...
        && length(S.subs) == 1
    if strcmp(class(This),class(X)) || isempty(X)
        nAlt = length(This);
        if ischar(S.subs) && strcmp(S.subs{1},':');
            lhs = 1 : nAlt;
        else
            lhs = S.subs{1};
        end
        if isempty(X)
            This = subsalt(This,lhs,[ ]);
        else
            nx = length(X);
            if nx == 1
                if islogical(lhs) && sum(lhs) > 1
                    rhs = ones(1,sum(lhs));
                elseif length(lhs) > 1
                    rhs = ones(1,length(lhs));
                else
                    rhs = 1;
                end
            else
                rhs = 1 : nx;
            end
            This = subsalt(This,lhs,X,rhs);
        end
    else
        utils.error('VAR:subsasgn',['#Invalid_assign:',class(This)]);
    end
else
    % Dot reference.
    This = builtin('subsasgn',This,S,X);
end

end
