function [B, flag] = mybmatrix(this, variantsRequested)
% mybmatrix  Matrix of instantaneous shock multipliers
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if nargin>=2 && isnumeric(variantsRequested)
    numVariantsRequested = numel(variantsRequested);
else
    numVariantsRequested = size(this.A, 3);
end

%--------------------------------------------------------------------------

flag = false;
ny = size(this.A, 1);
B = repmat(eye(ny), 1, 1, numVariantsRequested);

end%

