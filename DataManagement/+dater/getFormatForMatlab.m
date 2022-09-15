function matlabFormat = getFormatForMatlab(freq)

freq = round(double(freq));
switch freq
    case frequency.YEARLY
        matlabFormat = 'uuuu''Y''';
    case {frequency.HALFYEARLY, frequency.MONTHLY}
        matlabFormat = 'uuuu''M''MM';
    case frequency.QUARTERLY
        matlabFormat = 'uuuuQQQ';
    case {frequency.WEEKLY, frequency.DAILY}
        matlabFormat = 'uuuu-MMM-dd';
    otherwise
        matlabFormat = char.empty(1, 0);
end

end%

