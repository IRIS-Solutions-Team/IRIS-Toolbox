function yearly(This)
% yearly  Display tseries object one calendar year per row.
%
% Syntax
% =======
%
%     yearly(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object that will be displayed one full year
% of observations per row.
%
% Description
% ============
%
% The functon `yearly` currently works for tseries with monthly,
% bi-monthly, quarterly, and half-yearly frequency only.
%
% Example
% ========
%
% Create a quarterly tseries, and use `yearly` to display it one calendar
% year per row.
%
%     >> x = tseries(qq(2000,3):qq(2002,2),@rand)
%     x =
%         tseries object: 8-by-1
%         2000Q3:  0.95537
%         2000Q4:  0.68029
%         2001Q1:  0.86056
%         2001Q2:  0.93909
%         2001Q3:  0.68019
%         2001Q4:  0.91742
%         2002Q1:  0.25669
%         2002Q2:  0.88562
%         ''
%         user data: empty
%     >> yearly(x)
%         tseries object: 8-by-1
%         2000Q1-2000Q4:        NaN           NaN     0.9553698     0.6802907
%         2001Q1-2001Q4:  0.8605621     0.9390935      0.680194     0.9174237
%         2002Q1-2002Q4:  0.2566917     0.8856181           NaN           NaN
%         ''
%         user data: empty
%
    
% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

freq = DateWrapper.getFrequencyFromNumeric(This.start);

switch freq
    case {0,1,365}
        disp(This);
    otherwise
        % Call `disp` with yearly disp2d implementation.
        disp(This,'',@xxDisp2d);
end

end


% Subfunctions...


%**************************************************************************


function X = xxDisp2d(Start,Data,Tab,Sep,Num2StrFunc)
% `Data` is always a vector or a 2D matrix; no higher dimensions.
[nPer,nx] = size(Data);
freq = DateWrapper.getFrequencyFromNumeric(Start);
range = Start+(0:nPer-1);
[year,per] = dat2ypf(range);
firstYear = year(1);
lastYear = year(end);
piy = persinyear(firstYear : lastYear,freq);
nYear = lastYear - firstYear + 1;

if per(1) > 1
    nPre = per(1) - 1;
    Data = [nan(nPre,nx);Data];
    Start = Start - nPre;
end

if per(end) < piy(end)
    nPost = piy(end) - per(end);
    Data = [Data;nan(nPost,nx)];
end

nPer = size(Data,1);
range = Start+(0:nPer-1);
maxPiy = max(piy);

dataTable = [ ];
dates = [ ];
ixPadded = false(1,0);
for i = 1 : nYear
    n = piy(i);
    iData = Data(1:n,:);
    iRange = range(1:n);
    Data(1:n,:) = [ ];
    range(1:n) = [ ];
    isPadded = n < maxPiy;
    if isPadded
        iData = [iData;nan(maxPiy-n,nx)]; %#ok<AGROW>
    end
    ixPadded = [ixPadded,repmat(isPadded,1,nx)]; %#ok<AGROW>
    
    iFirstDate = iRange(1);
    iLastDate = iRange(end);
    dates = [dates; ...
        iFirstDate,iLastDate, ...
        ]; %#ok<AGROW>
    dataTable = [dataTable;iData.']; %#ok<AGROW>
end

dates = dat2str(dates);
dates = strcat(char(dates(:,1)),'-',char(dates(:,2)),Sep);
if nx > 1
    swap = dates;
    dates = repmat(' ',nx*nYear,size(dates,2));
    dates(1:nx:end,:) = swap;
end
dates = [ repmat(' ',1,size(dates,2)) ; dates ];

% Add header line with periods over columns.
dataChar = Num2StrFunc([1:maxPiy;dataTable]);

% Add the frequency letter to period numbers in the header line.
c = dataChar(1,:);
f = irisget('freqLetters');
f = f(freq == [1,2,4,6,12,52]);
c = regexprep(c,' (\d+)',[f,'$1']);
dataChar(1,:) = c;

% Replace `NaN` in periods that don't exist in the respective year with
% `*`.
for i = find(ixPadded)
    c = dataChar(1+i,:);
    c = regexprep(c,'NaN$','  *');
    dataChar(1+i,:) = c;
end

Tab = repmat(Tab,size(dates,1),1);
X = [Tab,dates,Tab,dataChar];
end % xxDisp2d( )
