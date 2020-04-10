function [realX, imagX] = splitRealImag(x)

inxZeroImag = imag(x)==0;
realX = real(x(inxZeroImag));

inxZeroReal = real(x)==0;
imagX = imag(x(inxZeroReal));

end%

