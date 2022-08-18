function X = mynanstd(X,Flag,Dim)

X = tseries.mynanvar(X,Flag,Dim);
X = sqrt(X);

end

