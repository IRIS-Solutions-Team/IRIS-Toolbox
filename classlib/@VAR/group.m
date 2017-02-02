function This = group(This,Grp)
% group  Retrieve VAR object from panel VAR for specified group of data.
%
% Syntax
% =======
%
%     V = group(V,Grp)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - Panel VAR object estimated on multiple groups of data.
%
% * `Grp` [ char ] - Requested group name; must be one of the names
% specified when the panel VAR object was constructed using the function
% [`VAR`](VAR/VAR).
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object for the `K`-th group of data.
%
% Description
% ============
%
% Example
% ========
%
% Create and estimate a panel VAR for three variables, `x`, `y`, `z`, and
% three countries, `US`, `EU`, `JA`. Then, retrieve a plain VAR for an
% individual country.
%
%     v = VAR({'x','y','z'},{'US','EU','JA'});
%     v = estimate(v,d,range,'fixedEffect=',true);
%     vi_us = group(v,'US');
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('V',@(x) isVAR(x) && ispanel(x));
pp.addRequired('Group',@(x) ischar(x) || isnumericscalar(x) || islogical(x));
pp.parse(This,Grp);

%--------------------------------------------------------------------------

if ischar(Grp)
    GrpName = Grp;
    Grp = strcmp(Grp,This.GroupNames);
    if ~any(Grp)
        utils.error('VAR:group', ...
            'This group does not exist in the %s object: ''%s''.', ...
            class(This),GrpName);
    end
end

if islogical(Grp)
    Grp = find(Grp);
    if length(Grp) ~= 1
        utils.error('VAR:group', ...
            'Exactly one group only must be requested.');
    end
end

try
    This.GroupNames = { };
    This.IxFitted = This.IxFitted(Grp,:,:);
    This.K = This.K(:,Grp,:);
    This.X0 = This.X0(:,Grp,:);
    if islogical(Grp)
        Grp = find(Grp);
    end
    nx = length(This.XNames);
    pos = (Grp-1)*nx + (1:nx);
    This.J = This.J(:,pos,:);
    
catch
    utils.error('VAR:group', ...
        'This group does not exist in the %s object: %g.', ...
        class(This),Grp);
end

end
