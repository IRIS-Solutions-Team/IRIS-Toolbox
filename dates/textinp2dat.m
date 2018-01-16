function [dat, str] = textinp2dat(str)
% textinp2dat  Convert text input to IRIS serial date numbers.
%
%
% Syntax
% =======
%
%     Dat = textinp2dat(Str)
%
%
% Input arguments
% ================
%
% * `Str` [ char ] - String describing a date, a vector of dates, or a
% range; see Description.
%
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers representing the input
% date, vector of dates, or range.
%
%
% Description
% ============
%
% Input text strings can contain dates in the basic format, for instance
% `2010Y` for yearly dates, `2010H1` for half-yearly dates, `2010Q2` for
% quarterly dates, `2010B6` for bi-monthly dates, `2010M09` for monthly
% dates, `2010W52` for weekly dates, or `2010-May-30` for daily dates. Each
% occurrence of a date will be replaced with a call to the respective IRIS
% date function, `yy(...)`, `hh(...)`, `qq(...)`, `bb(...)`, `mm(...)`,
% `ww(...)`, or `dd(...)`, and the resulting expression will be evaluated,
% converting it into a vector of IRIS serial date numbers.
%
%
% Example
% ========
%
%     >> textinp2dat('2010Q1:2011Q4')
%     ans =
%        1.0e+03 *
%       Columns 1 through 7
%         8.0400    8.0410    8.0420    8.0430    8.0440    8.0450    8.0460
%       Column 8
%         8.0470
%     >> dat2str( textinp2dat('2010Q1:2011Q4') )
%     ans =
%       Columns 1 through 6
%         '2010Q1'    '2010Q2'    '2010Q3'    '2010Q4'    '2011Q1'    '2011Q2'
%       Columns 7 through 8
%         '2011Q3'    '2011Q4'
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

Str0 = str;

str = regexprep(str, ...
    '(\d+)([YHQBMW])(\d{0,2})', ...
    '${lower([$2,$2])}($1,max([$3,1]))', ...
    'ignorecase');

str = regexprep(str, ...
    '(\d+)\-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\-(\d+)', ...
    'dd($1,''$2'',$3)', ...
    'ignorecase');

try
    dat = eval(str);
    ok = isnumeric(dat);
catch
    ok = false;
end

if ~ok
    utils.error('dates:textinp2dat', ...
        'This conversion from text input to dates failed: ''%s''.', ...
        Str0);
end

end
