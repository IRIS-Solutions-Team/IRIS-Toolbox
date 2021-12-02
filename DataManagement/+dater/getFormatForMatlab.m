function matlabFormat = getFormatForMatlab(freq)

switch round(double(freq))
    case Frequency__.Yearly
        matlabFormat = 'uuuu''Y''';
    case {Frequency__.HalfYearly, Frequency__.Monthly}
        matlabFormat = 'uuuu''M''MM';
    case Frequency__.Quarterly
        matlabFormat = 'uuuuQQQ';
    case {Frequency__.Weekly, Frequency__.Daily}
        matlabFormat = 'uuuu-MMM-dd';
    otherwise
        matlabFormat = char.empty(1, 0);
end

end%

