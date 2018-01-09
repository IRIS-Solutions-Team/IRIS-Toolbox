function varargout = comment(this, varargin)
% comment  Get or set user comments in a tseries object.
%
%
% Syntax for getting user comments
% =================================
%
%     ColumnNames = comment(X)
%
%
% Syntax for assigning user comments
% ===================================
%
%     X = comment(X, ColumnNames)
%     X = comment(X, Y)
%
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Time series.
%
% * `ColumnNames` [ char | cellstr ] - Comment(s) that will be assigned
% to each column of the input time series, `X`.
%
% * `Y` [ tseries ] - Another time series whose column comment(s) will be
% assigned to the input time series, `X`.
%
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output time series with new comments.
%
% * `ColumnNames` [ cellstr ] - Column comments from the input time
% series, `X`.
%
%
% Description
% ============
%
% Multivariate time series (i.e. tseries objects) have comments assigned to
% each of their columns. When assigning comments (using the syntax with two
% input arguments) you can either pass in a char (text string) or a cellstr
% (a cell array of strings). If `ColumnNames` is a char, then this same
% comment will be assigned to all of the tseries columns. If
% `ColumnNames` is a cellstr, its size in the 2nd and higher dimensions
% must match the size of the tseries data; the individual strings from
% `ColumnNames` will be then copied to the comments belonging to the
% individual tseries columns.
%
%
% Example
% ========
%
%     x = tseries(1:2, rand(2, 2));
%     x = comment(x, 'Comment')
%
%     x =
% 
%         tseries object: 2-by-2
% 
%         1: 0.28521     0.67068
%         2: 0.91586     0.78549
%         'Comment'    'Comment'
% 
%         user data: empty
% 
%     x = comment(x, {'Comment 1', 'Comment 2'})
% 
%     x =
% 
%         tseries object: 2-by-2
% 
%         1: 0.28521     0.67068
%         2: 0.91586     0.78549
%         'Comment 1'    'Comment 2'
% 
%         user data: empty
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries/comment');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'tseries'));
    INPUT_PARSER.addOptional('ColumnNames', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || isa(x, 'string') || isa(x, 'tseries'));
end

INPUT_PARSER.parse(this, varargin{:});

if ismember('ColumnNames', INPUT_PARSER.UsingDefaults)
    action = 'get';
else
    action = 'set';
    columnNames = INPUT_PARSER.Results.ColumnNames;
end

%--------------------------------------------------------------------------

varargout = cell(1, 1);

% Get comments
%--------------
if isequal(action, 'get')
    varargout{1} = this.Comment;
    return
end

% Set comments
%--------------
if isa(columnNames, 'tseries')
    columnNames = columnNames.Comment;
end
this.ColumnNames = columnNames;
varargout{1} = this;

end
