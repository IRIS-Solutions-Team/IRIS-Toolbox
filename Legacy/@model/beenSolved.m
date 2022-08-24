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

% Transition matrix can be empty in 2nd dimension (no lagged variables)
if size(T, 1)>0 && size(T, 2)==0
    flag = true(1, size(T, 3));
else
    flag = all(all(isfinite(T), 1), 2) & all(all(isfinite(R), 1), 2);
    flag = reshape(flag, 1, [ ]);
end

end%

