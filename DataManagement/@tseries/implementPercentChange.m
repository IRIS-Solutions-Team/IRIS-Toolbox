function X = implementPercentChange(X, S, Q)
% implementPercentChange  Percent rate of change.
%
% Backend IRIS function.
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

pos = transpose(1:size(X, 2));
pos = pos(:, ones(1, length(S)));
pos = transpose(pos(:));

X = X(:, pos) ./ tseries.myshift(X, S);
if Q~=1
    X = X .^ Q;
end
X = 100*(X - 1);

end
