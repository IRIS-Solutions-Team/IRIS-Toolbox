function [realX, imagX] = splitRealImag(x, valueToRemove)

if nargin<2
    valueToRemove = 0;
end

realX = real(x);
imagX = imag(x);

if isscalar(valueToRemove)
    realX(realX==valueToRemove) = [ ];
    imagX(imagX==valueToRemove) = [ ];
end

end%

