function [B,Flag] = mybmatrix(This,Alt)
% mybmatrix  [Not a public function] Matrix of instantaneous effects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

try
    Alt; %#ok<VUNUS>
    if isnumericscalar(Alt)
        n3 = 1;
    else
        n3 = size(This.A,3);
    end
catch
    n3 = size(This.A,3);
end

%--------------------------------------------------------------------------

Flag = false;

ny = size(This.A,1);
B = eye(ny);
B = B(:,:,ones(1,n3));

end