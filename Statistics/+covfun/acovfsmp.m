function C = acovfsmp(X, opt)
% acovfsmp  Sample autocovariance function
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

sizeOfX = size(X);
X = X(:, :, :);
[numOfPeriods, numOfX, numOfPages] = size(X);

if isinf(opt.Order)
    opt.Order = numOfPeriods - 1;
    if opt.SmallSample
        opt.Order = opt.Order - 1;
    end
end

if opt.Demean
    X = bsxfun(@minus, X, mean(X, 1));
end

C = zeros(numOfX, numOfX, 1+opt.Order, numOfPages);
for page = 1 : numOfPages
    xi = X(:, :, page);
	if opt.SmallSample
		T = numOfPeriods - 1;
	else
		T = numOfPeriods;
	end
    C(:, :, 1, page) = xi.'*xi / T;
    for order = 1 : opt.Order
        if opt.SmallSample
            T = T - 1;
        end
        C(:, :, order+1, page) = xi(1:end-order, :).'*xi(1+order:end, :) / T;
    end
end

if length(sizeOfX)>3
    C = reshape(C, [numOfX, numOfX, 1+opt.Order, sizeOfX(3:end)]);
end

end%

