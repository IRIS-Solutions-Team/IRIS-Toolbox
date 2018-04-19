function this = trim(this)
% trim  Remove leading and trailing missing values from time series data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

[this.Data, this.Start] = this.trimRows(this.Data, this.Start, this.MissingValue, this.MissingTest);

end

%{
x = this.Data;
if isempty(x)
    if size(this.Data, 1)==0
        return
    end
    this = this.empty(this);
    return
end

isMissing = this.MissingTest;

if isreal(x)
    if ~any(any(isMissing(x([1, end], :))))
        return
    end
    indexOfMissing = all(isMissing(x(:, :)), 2);
else
    realX = real(x);
    imagX = imag(x);
    if ~any(any( isMissing(realX([1, end], :)) & isMissing(imagX([1, end], :)) ))
        return
    end
    indexOfMissing = all( isMissing(realX(:, :)) & isMissing(imagX(:, :)) , 2);
end

newSize = size(x);
if all(indexOfMissing)
    this.Start = DateWrapper.NaD( );
    newSize(1) = 0;
    this.Data = repmat(this.MissingValue, newSize);
else
    posOfFirstMissing = find(~indexOfMissing, 1);
    posOfLastMissing = find(~indexOfMissing, 1, 'last');
    x = x(posOfFirstMissing:posOfLastMissing, :);
    newSize(1) = round(posOfLastMissing - (posOfFirstMissing - 1));
    this.Data = reshape(x, newSize);
    this.Start = DateWrapper(double(this.Start) + posOfFirstMissing - 1);
end

end
%}
