function [outputDate, dateString] = textinp2dat(dateString)
% textinp2dat  Convert text input to DateWrapper objects
%
%
% __Syntax__
%
%     date = textinp2dat(dateString)
%
%
% __Input Arguments__
%
% * `dateString` [ char | string ] - String describing a date, a vector of
% dates, or a range; see Description.
%
%
% __Output Arguments__
%
% * `date` [ DateWrapper ] - DateWrapper object representing the input
% date, vector of dates, or range.
%
%
% __Description__
%
% Input text strings can contain dates in the basic format, for instance
% `2010Y` for yearly dates, `2010H1` for half-yearly dates, `2010Q2` for
% quarterly dates, `2010B6` for bi-monthly dates, `2010M09` for monthly
% dates, `2010W52` for weekly dates, or `2010-May-30` for daily dates. Each
% occurrence of a date will be replaced with a call to the respective IRIS
% date function, `yy(...)`, `hh(...)`, `qq(...)`, `mm(...)`, `ww(...)`, or
% `dd(...)`, and the resulting expression will be evaluated, converting it
% into a vector of DateWrapper objects.
%
%
% __Example__
%
%     >> textinp2dat('2010Q1:2010Q4')
%     ans = 
%       1x8 QUARTERLY Date(s)
%         '2010Q1'    '2010Q2'    '2010Q3'    '2010Q4'
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

[dateCode, dateString] = numeric.textinp2dat(dateString);
outputDate = DateWrapper(dateCode);

end%

