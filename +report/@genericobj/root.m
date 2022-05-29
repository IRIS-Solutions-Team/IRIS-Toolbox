function X = root(This,varargin)
% root  [Not a public funtion ] Return a handle to the root report object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = This;
while ~isequal(X.parent,[ ])
    X = X.parent;
end

end
