function y = xfloor(x, floor, c)
% xfloor  Numerical approximation to max(x,floor).

z = x - floor;
y = floor + z.*(erf(c*z) + 1) / 2;
% dy = (erf(c*z)+1)/2 + z.*exp(-z.^2)/sqrt(pi);
end