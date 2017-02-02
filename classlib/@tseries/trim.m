function this = trim(this)
% trim  Remove leading and trailing NaNs from time series data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

this.Stamp = clock( );

x = this.Data;
if isempty(x)
    return
end

if isreal(x)
    if ~any(any(isnan(x([1, end], :))))
        return
    end
    ixNan = all(isnan(x(:, :)), 2);
else
    realX = real(x);
    imagX = imag(x);
    if ~any(any( isnan(realX([1, end], :)) & isnan(imagX([1, end], :)) ))
        return
    end
    ixNan = all( isnan(realX(:, :)) & isnan(imagX(:, :)) , 2);
end

newSize = size(x);
if all(ixNan)
    this.Start = NaN;
    newSize(1) = 0;
    this.Data = zeros(newSize);
else
    first = find(~ixNan, 1);
    last = find(~ixNan, 1, 'last');
    x = x(first:last, :);
    newSize(1) = last - first + 1;
    this.Data = reshape(x, newSize);
    this.Start = this.Start + first - 1;
end

end
