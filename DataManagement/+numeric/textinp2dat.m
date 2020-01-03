function [date, dateString] = textinp2dat(dateString)
% textinp2dat  Convert text input to IRIS date codes
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
% * `date` [ numeric ] - IRIS date code representing the input
% date, vector of dates, or range.
%
%
% __Description__
%
% Input text strings can contain dates in the basic format, for instance
% `2010Y` for yearly dates, `2010H1` for half-yearly dates, `2010Q2` for
% quarterly dates, `2010M09` for monthly dates, `2010W52` for weekly dates,
% or `2010-May-30` for daily dates. Each occurrence of a date will be
% replaced with a call to the respective IRIS date function, `yy(...)`,
% `hh(...)`, `qq(...)`, `mm(...)`, `ww(...)`, or `dd(...)`, and the
% resulting expression will be evaluated, converting it into a vector of
% IRIS date codes.
%
%
% __Example__
%
%     >> numeric.textinp2dat('2010Q1:2010Q4')
%     ans =
%        1.0e+03 *
%       Columns 1 through 7
%         8.0400    8.0410    8.0420    8.0430
%     >> dat2str( numeric.textinp2dat('2010Q1:2010Q4') )
%     ans =
%       Columns 1 through 6
%         '2010Q1'    '2010Q2'    '2010Q3'    '2010Q4' 
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

inputDateString = dateString;

dateString = regexprep( dateString, ...
                        '(\d+)([YHQMW])(\d{0,2})', ...
                        'numeric.${lower([$2,$2])}($1,max([$3,1]))', ...
                        'ignorecase' );

dateString = regexprep( dateString, ...
                        '(\d+)\-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\-(\d+)', ...
                        'numeric.dd($1,''$2'',$3)', ...
                        'ignorecase' );

try
    date = eval(dateString);
    ok = isnumeric(date);
catch
    ok = false;
end

if ~ok
    THIS_WARNING = { 'Dates:ConversionFromTextInputFailed' 
                     'Conversion of this text input to dates failed: %s ' };
    throw( exception.Base(THIS_WARNING, 'error'), ...
           inputDateString );
end

end%

