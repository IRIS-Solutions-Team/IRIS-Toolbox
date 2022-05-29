% dbase  Basic Database Management.
%
%
% Loading and saving databases
% =============================
%
% * [`dbload`](dbase/dbload) - Create database by loading CSV file.
% * [`dbsave`](dbase/dbsave) - Save database as CSV file.
% * [`xls2csv`](dbase/xls2csv) - Convert XLS file to CSV file.
%
%
% Getting information about databases
% ====================================
%
% * [`dbnames`](dbase/dbnames) - List of database entries filtered by name and/or class.
% * [`dbprintuserdata`](dbase/dbprintuserdata) - Print names of database tseries along with specified fields of their userdata.
% * [`dbrange`](dbase/dbrange) - Find a range that encompasses the ranges of the listed tseries objects.
% * [`dbsearchuserdata`](dbase/dbsearchuserdata) - Search database to find tseries by matching the content of their userdata fields.
% * [`dbuserdatalov`](dbase/dbuserdatalov) - List of values found in a specified user data field in tseries objects.
%
%
% Converting databases
% =====================
%
% * [`array2db`](dbase/array2db) - Convert numeric array to database.
% * [`db2array`](dbase/db2array) - Convert tseries database entries to numeric array.
% * [`db2tseries`](dbase/db2tseries) - Combine tseries database entries in one multivariate tseries object.
%
%
% Batch processing
% =================
%
% * [`dbbatch`](dbase/dbbatch) - Run a batch job to create new database fields.
% * [`dbclip`](dbase/dbclip) - Clip all tseries entries in database down to specified date range.
% * [`dbcol`](dbase/dbcol) - Retrieve the specified column or columns from database entries.
% * [`dbcomment`](dbase/dbcomment) - Create model-based comments for database tseries entries.
% * [`dbfill`](dbase/dbfill) - 
% * [`dbfun`](dbase/dbfun) - Apply function to database fields.
% * [`dbplot`](dbase/dbplot) - Plot from database.
% * [`dbpage`](dbase/dbpage) - Retrieve the specified page or pages from database entries.
% * [`dbredate`](dbase/dbredate) - Redate all tseries objects in a database.
%
%
% Combining and splitting databases
% ==================================
%
% * [`dboverlay`](dbase/dboverlay) - Combine tseries observations from two or more databases.
% * [`dbmerge`](dbase/dbmerge) - Merge two or more databases.
% * [`dbminuscontrol`](dbase/dbminuscontrol) - Create simulation-minus-control database.
% * [`dbsplit`](dbase/dbsplit) - Split database into mutliple databases.
%
%
% Overloaded operators for databases
% ===================================
%
% * [`-`](dbase/dbminus) - Remove entries from a database.
% * [`*`](dbase/dbmtimes) - Keep only the database entries that are on the list.
% * [`+`](dbase/dbplus) - Merge entries from two databases together.
%
%
% Getting on-line help on database functions
% ===========================================
%
%     help dbase
%     help dbase/function_name
%


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
