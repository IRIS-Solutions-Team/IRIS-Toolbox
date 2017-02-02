function hdatainit(This,H)
% hdatainit  [Not a public function] Initialise hdataobj for VAR.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
nx = length(This.XNames);
ne = ny;
ni = length(This.INames);

H.Id = { 1:ny, ny+(1:nx), ny+nx+(1:ne), ny+nx+ne+(1:ni) };
H.Name = [ This.YNames, This.XNames, This.ENames, This.INames ];
H.IxLog = false(size(H.Name));
H.Label = [ This.YNames, This.XNames, This.ENames, This.INames ];

if isequal(H.Contributions,@shock)
    H.Contributions = [ This.ENames, {'Init+Const'}, {'Exog'} ];
elseif isequal(H.Contributions,@measurement)
    H.Contributions = This.YNames;
end

end
