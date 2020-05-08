function x = overlay(func, x, varargin)
% numeric.overlay  Replace the input array values that satisfy a test with
% values from another array
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

for a = varargin
    inxOverlay = func(x);
    if any(inxOverlay(:))
        if isscalar(a{:})
            x(inxOverlay) = a{:};
        else
            x(inxOverlay) = a{:}(inxOverlay);
        end
    end
end

end%

