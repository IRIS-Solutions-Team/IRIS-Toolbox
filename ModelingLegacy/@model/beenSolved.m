% beenSolved  True if first-order solution has been successfully calculated
%{
% Syntax
%--------------------------------------------------------------------------
%
%
%     flag = beenSolved(model)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`model`__ [ model ]
%
%     Model object.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`flag`__ [ `true` | `false` ]
%
%     True for parameter variants for which a stable unique solution has
%     been successfully calculated.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% ### Basic Use Case ###
%
%
% Use this function to verify whether a first-order solution has been
% successfully calculated and assigned in the model object. The output
% argument, `flag`, is `true` if a valid solution exists in the model
% object and `false` if it does not.
% 
%
% ### Models with Multiple Parameter Variants ###
%
%
% If the input model, `m`, contains multiple parameter variants, the output
% argument, `flag`, is a row vector of logical values of the same length as
% the number of variants, each element of which indicates the existence of
% a valid first-order solution for the respective parameter variant.
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function flag = beenSolved(this, variantsRequested)

try, variantsRequested;
    catch, variantsRequested = ':'; end

%--------------------------------------------------------------------------

% Models with no equations return false
if size(this.Variant.FirstOrderSolution{1}, 1)==0
    flag = false(1, countVariants(this));
    return
end

T = this.Variant.FirstOrderSolution{1}(:, :, variantsRequested);
R = this.Variant.FirstOrderSolution{2}(:, :, variantsRequested);
% Transition matrix can be empty in 2nd dimension (no lagged
% variables)
if size(T, 1)>0 && size(T, 2)==0
    flag = true(1, size(T, 3));
else
    flag = all(all(isfinite(T), 1), 2) & all(all(isfinite(R), 1), 2);
    flag = reshape(flag, 1, [ ]);
end

end%

