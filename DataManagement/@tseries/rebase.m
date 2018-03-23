function x = rebase(x, date, b)
% rebase  Rebase times seris data to specified period.
%
%
% __Syntax__
%
%     X = rebase(X, Date, B...)
%
%
% __Input arguments__
%
% * `X` [ Series | tseries ] -  Input time series that will be normalized.
%
% * `Date` [ DateWrapper | `'start'` | `'end'` | `'nanStart'` | `'nanEnd'`
% ] - Date relative to which the input data will be normalized; if not
% specified, `'nanStart'` (the first date for which all columns have an
% observation) will be used.
%
% * `B` [ `0` | `1` | `100` ] - Rebasing mode: `B=0` means additive
% rebasing with `0` in the base period; `B=1` means multiplicative rebasing
% with `1` in the base period; `B=100` means multiplicative rebasing with
% `100` in the base period;
%
%
% __Output arguments__
%
% * `X` [ Series | tseries ] - Normalized time series.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

try, date; catch, date = 'NanStart'; end %#ok<VUNUS,NOCOM>
try, b; catch, b = 1; end %#ok<VUNUS,NOCOM>

if ischar(date)
    if DateWrapper.validateDateInput(date)
        date = textinp2dat(date);
    else
        date = get(x, date);
    end
end

%--------------------------------------------------------------------------

if b==0
    func = @minus;
    value = 0;
elseif b==1
    func = @rdivide;
    value = 1;
elseif b==100
    func = @rdivide;
    value = 100;
end

xSize = size(x.data);
x.data = x.data(:,:);

y = mygetdata(x, date);
for i = 1 : size(x.data, 2)
    x.data(:,i) = func(x.data(:,i), y(i));
end

if length(xSize)>2
    x.data = reshape(x.data, xSize);
end

if value==100
    x.data = x.data * value;
end

x = trim(x);

end
