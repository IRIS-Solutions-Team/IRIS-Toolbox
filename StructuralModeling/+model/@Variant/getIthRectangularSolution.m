function [T, R, K, Z, H, D, Y] = getIthRectangularSolution(this, v)

numVariants = size(this.Values, 3);

if numVariants==1
    T = this.FirstOrderSolution{1};
    R = this.FirstOrderSolution{2};
    K = this.FirstOrderSolution{3};
    Z = this.FirstOrderSolution{9};
    H = this.FirstOrderSolution{5};
    D = this.FirstOrderSolution{6};
    U = this.FirstOrderSolution{7};
    Y = this.FirstOrderSolution{8};
    T0 = this.FirstOrderSolution{10};
else
    T = this.FirstOrderSolution{1}(:, :, v);
    R = this.FirstOrderSolution{2}(:, :, v);
    K = this.FirstOrderSolution{3}(:, :, v);
    Z = this.FirstOrderSolution{9}(:, :, v);
    H = this.FirstOrderSolution{5}(:, :, v);
    D = this.FirstOrderSolution{6}(:, :, v);
    U = this.FirstOrderSolution{7}(:, :, v);
    Y = this.FirstOrderSolution{8}(:, :, v);
    T0 = this.FirstOrderSolution{10};
    if ~isempty(T0)
        T0 = T0(:, :, v);
    end
end
    
numXif = size(T, 1) - size(T, 2);

if ~isempty(T0)
    T = T0;
else
    % Bkw compatibility for older models saved to mat files
    if ~isempty(U)
        T = T / U;
        T(numXif+1:end, :) = U*T(numXif+1:end, :);
    end
end

if ~isempty(U)
    R(numXif+1:end, :) = U*R(numXif+1:end, :);
    K(numXif+1:end, :) = U*K(numXif+1:end, :);
    if ~isempty(Y)
        Y(numXif+1:end, :) = U*Y(numXif+1:end, :);
    end
end

end%

