function tabular(this)

switch this.Frequency
    case {frequency.INTEGER, frequency.YEARLY}
        disp(this);
    case {frequency.DAILY}
        disp(this, '', 'disp2dDaily');
    otherwise
        disp(this, '', 'disp2dYearly');
end

end%
