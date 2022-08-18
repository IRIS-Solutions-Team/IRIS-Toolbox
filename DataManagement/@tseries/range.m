function outputRange = range(x)

if isempty(x.Data)
    outputRange = nan(1, 0);
else
    numRows = size(x.Data, 1);
    outputRange = dater.plus(double(x.Start), 0:numRows-1);
end
outputRange = Dater(outputRange);

end%

