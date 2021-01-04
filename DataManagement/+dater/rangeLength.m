function len = rangeLength(range, varargin)

range = double(range);
startRange = range(1);
if nargin==1
    endRange = range(end);
else
    endRange = double(varargin{1});
end

len = (round(100*endRange) - round(100*startRange)) / 100;
inxValid = isfinite(len) & len==round(len);
inxPositive = inxValid & len>=0;
inxNegative = inxValid & len<0;

if any(inxPositive)
    len(inxPositive) = len(inxPositive) + 1;
end

if any(inxNegative)
    len(inxNegative) = len(inxNegative) - 1;
end

if any(~inxValid)
    len(~inxValid) = NaN;
end

end%

