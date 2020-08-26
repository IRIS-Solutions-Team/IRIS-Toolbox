function listSaved = toCSV(inputDatabank, fileName, varargin);
% toCSV  Serialize databank and save to CSV file
%{
% ## Syntax ##
%
%     listSaved = databank.toCSV(d, fileName, dates, ...)
%
%
% ## Input Arguments ##
%
%
% __`inputDatabank`__ [ struct | Dictionary | containers.Map ] -
% >
% Input databank whose time series and numeric entries will be serialized
% to a character vector.
%
%
% __`fileName`__ [ char | string ] -
% >
% Name of a CSV file to which the databank will be saved.
%
%
% __`dates`__ [ DateWrapper | numeric | `Inf`  ] - 
% >
% Dates or date range on which the time series will be saved; `Inf` means
% a date range from the earliest date found in the `inputDatabank` to the
% latest date.
% 
%
% ## Output Arguments ##
%
%
% __`c`__ [ char ] - 
% >
% Character vector representing the databank.
%
%
% __`listSaved`__ [ cellstr ] -
% >
% List of databank entries that have been serialized and saved to
% `fileName`.
%
%
% ## Options ##
%
%
% __`VariablesHeader='Variables->'`__ [ char ] - 
% >
% String that will be put in the top-left corncer (cell A1).
%
%
% __`Class=true`__ [ `true` | `false` ] - 
% >
% Include a row with class and size specifications.
%
%
% __`Comment=true`__ [ `true` | `false` ] - 
% >
% Include a row with comments for time series.
%
%
% __`Decimals=[ ]`__ [ numeric ] - 
% >
% Number of decimals up to which the data
% will be saved; if empty the option `Format=` is used.
%
%
% __`Format='%.8e'`__ [ char ] - 
% >
% Numeric format that will be used to
% represent the data, see `sprintf` for details on formatting, The format
% must start with a `'%'`, and must not include identifiers specifying
% order of processing, i.e. the `'$'` signs, or left-justify flags, the
% `'-'` signs.
%
%
% __`FreqLetters=@config`__ [ `@config` | char ] - 
% >
% Six letters to represent
% the five possible date frequencies except daily and integer (annual,
% semi-annual, quarterly, bimonthly, monthly, weekly); `@config` means the
% frequency letters will be read from the current IRIS configuration.
%
%
% __`MatchFreq=false`__ [ `true` | `false` ] - 
% >
% Save only those time series
% whose date frequencies match the input vector of dates, `Dates`.
%
%
% __`NaN='NaN'`__ [ char ] - 
% >
% String that will be used to represent NaNs.
%
%
% __`UserData='UserData__'`__ [ char ] - 
% >
% Field name in the `inputDatabank` from which any kind of user data will
% be read, serialized, and saved to the CSV file.
% 
%
% __`UserDataFields={ }`__ [ empty | cellstr | string ]
% >
% List of user data fields that will be extracted from each time series
% object, and saved to the CSV file; the name of the row where each user
% data field is saved is `.xxx` where `xxx` is the name of the user data
% field.
%
%
% ## Description ##
%
%
% The data serialized include also imaginary parts of complex numbers.
%
%
% ### Saving Databank-Wide User Data ###
%
%
% If your database contains field named `UserData`, this will be saved
% in the CSV file on a separate row. The `UserData` field can be any
% combination of numeric, char, and cell arrays and 1-by-1 structs.
%
% You can use the `UserData` field to describe the database or preserve
% any sort of metadata. To change the name of the field that is treated as
% user data, use the `UserData` option.
%
%
% ## Example ##
%
%
% Create a simple database with two time series.
%
%     D = struct( );
%     D.x = Series(qq(2010, 1):qq(2010, 4), @rand);
%     D.y = Series(qq(2010, 1):qq(2010, 4), @rand);
%
% Add your own description of the database, e.g.
%
%     D.UserData = {'My database', datestr(now( ))};
%
% Save the database as CSV using `databank.toCSV`, 
%
%     databank.toCSV(D, 'mydatabase.csv');
%
% When you later load the database, 
%
%     D = databank.fromCSV('mydatabase.csv')
%
%     D = 
%
%        UserData: {'My database'  '23-Sep-2011 14:10:17'}
%               x: [4x1 Series]
%               y: [4x1 Series]
%
% the database will preserve the `'UserData''` field.
%
%
% ## Example ##
%
%
% To change the field name under which you store your own user data, use
% the option `UserData=` when running `databank.toCSV`, 
%
%     D = struct( );
%     D.x = Series(qq(2010, 1):qq(2010, 4), @rand);
%     D.y = Series(qq(2010, 1):qq(2010, 4), @rand);
%     D.DB_USER_DATA = {'My database', datestr(now( ))};
%     databank.toCSV(D, 'mydatabase.csv', Inf, 'UserData=', 'DB_USER_DATA');
%
% The name of the user data field is also kept in the CSV file so that
% `databank.fromCSV` works fine in this case, too, and returns a database
% identical to the saved one, 
%
%     D = databank.fromCSV('mydatabase.csv')
%
%     D = 
%
%        DB_USER_DATA: {'My database'  '23-Sep-2011 14:10:17'}
%                   x: [4x1 Series]
%                   y: [4x1 Series]
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%( Input parser
persistent parser
if isempty(parser)
    parser = extend.InputParser('+databank/toCSV');
    addRequired(parser, 'fileName', @validate.string);
end
%)
parse(parser, fileName);

[c, listSaved] = databank.serialize(inputDatabank, varargin{:});
char2file(c, fileName);

end%

