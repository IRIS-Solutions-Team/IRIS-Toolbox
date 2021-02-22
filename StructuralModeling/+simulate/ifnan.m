function varargout = ifnan(input, replace)
% ifnan  Replace NaNs with another value
%{
% ## Syntax ##
%
%
%     output = simulate.ifnan(input, replace)
%
%
% ## Input Arguments ##
%
%
% __`input`__ [ numeric ]
% >
% Numeric array whose NaNs will be replaced with the `replace` value.
%
%
% __`replace`__ [ numeric ]
% >
% Numeric scalar or a numeric array of the same size as `input` whose
% values will used to replace NaNs in the `input`.
%
%
% ## Output Arguments ##
%
%
% __`output`__ [ numeric ]
% >
% The `input` array with its NaNs replaced with `replace`.
%
%
% ## Description ##
%
%
% ## Example ##
%
%
% In the first example, replace each NaN with the same value
%
%     >> x = [1, NaN, 3, NaN];
%     >> simulate.ifnan(x, 10)
%     ans =
%          1    10     3    10
%
%
% In the second example, replace eaach NaN with the corresponding element
% of the `replace` array:
%
%     >> simulate.ifnan(x, [10, 20, 30, 40])
%     ans =
%          1    20     3    40
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

inxNaN = isnan(input);
if any(inxNaN(:))
    if numel(replace)==1
        input(inxNaN) = replace;
    else
        input(inxNaN) = replace(inxNaN);
    end
end

varargout{1} = input;

end%

