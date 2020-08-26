function matlabFormat = getFormatForMatlab(freq)

switch round(double(freq))
    case Frequency.YEARLY
        matlabFormat = 'uuuu''Y''';
    case {Frequency.HALFYEARLY, Frequency.MONTHLY}
        matlabFormat = 'uuuu''M''MM';
    case Frequency.QUARTERLY
        matlabFormat = 'uuuuQQQ';
    case {Frequency.WEEKLY, Frequency.DAILY}
        matlabFormat = 'uuuu-MMM-dd';
    otherwise
        matlabFormat = char.empty(1, 0);
end

end%

