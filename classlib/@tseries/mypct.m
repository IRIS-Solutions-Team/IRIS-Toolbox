function X = mypct(X,S,Q)
% mypct  [Not a public function] Percent rate of change.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    S; %#ok<VUNUS>
catch %#ok<CTCH>
    S = -1;
end

try
    Q; %#ok<VUNUS>
catch %#ok<CTCH>
    Q = 1;
end

%--------------------------------------------------------------------------

S = S(:).';

inx = transpose(1:size(X,2));
inx = inx(:,ones(1,length(S)));
inx = transpose(inx(:));

X = X(:,inx) ./ tseries.myshift(X,S);
if Q ~= 1
    X = X .^ Q;
end
X = 100*(X - 1);

end