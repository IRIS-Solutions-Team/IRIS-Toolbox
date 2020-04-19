function [realX, imagX] = splitRealImag(x)

realX = real(x);
realX(realX==0) = [ ];

imagX = imag(x);
imagX(imagX==0) = [ ];

end%

