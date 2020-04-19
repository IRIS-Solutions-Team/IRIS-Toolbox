function unionX = unionRealImag(x)

[realX, imagX] = iris.utils.splitRealImag(x);
unionX = union(realX, imagX, 'stable');

end%

