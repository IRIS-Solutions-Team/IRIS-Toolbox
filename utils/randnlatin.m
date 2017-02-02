function [X,Z] = randnlatin(P,N)
% randnlatin  Latin hypercube sample from standard normal distribution.

X = randn(P,N);
if nargout > 1
    Z = X;
end

for i = 1 : P
   X(i,:) = xxRank(X(i,:));
end

X = X - rand(size(X));
X = X / N;
X = xxNormInv(X);

end

% Subfunctions.

%**************************************************************************
function r = xxRank(x)
x = x(:);
[~,rowIdx] = sort(x);
r(rowIdx) = 1 : length(x);
r = r(:);
end % xxRank( ).

%**************************************************************************
function x = xxNormInv(p)
x = -sqrt(2).*erfcinv(2*p);
end % xxNormInv( ).