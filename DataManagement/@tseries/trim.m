function this = trim(this)
% trim  Remove leading and trailing NaNs from time series data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

x = this.Data;
if isempty(x)
    return
end

if isreal(x)
    if ~any(any(isnan(x([1, end], :))))
        return
    end
    indexNaN = all(isnan(x(:, :)), 2);
else
    realX = real(x);
    imagX = imag(x);
    if ~any(any( isnan(realX([1, end], :)) & isnan(imagX([1, end], :)) ))
        return
    end
    indexNaN = all( isnan(realX(:, :)) & isnan(imagX(:, :)) , 2);
end

newSize = size(x);
if all(indexNaN)
    this.Start = DateWrapper.NaD( );
    newSize(1) = 0;
    this.Data = double.empty(newSize);
else
    posFirstNaN = find(~indexNaN, 1);
    posLastNaN = find(~indexNaN, 1, 'last');
    x = x(posFirstNaN:posLastNaN, :);
    newSize(1) = posLastNaN - (posFirstNaN - 1);
    this.Data = reshape(x, newSize);
    this.Start = DateWrapper(double(this.Start) + posFirstNaN - 1);
end

end
