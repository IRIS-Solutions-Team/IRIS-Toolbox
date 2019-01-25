function varargout = comment(this, varargin)
% comment  Get or set user comments in time series
%
%
% __Syntax for Getting User Comments__
%
%     newComment = comment(x)
%
%
% __Syntax for Assigning User Comments__
%
%     x = comment(x, newComment)
%     x = comment(x, y)
%
%
% __Input Arguments__
%
% * `x` [ TimeSubscriptable ] - Time series
%
% * `newComment` [ char | cellstr ] - Comment(s) that will be assigned
% to each column of the input time series, `x`.
%
% * `y` [ TimeSubscriptable ] - Another time series whose column comment(s) will be
% assigned to the input time series, `x`.
%
%
% Output arguments
% =================
%
% * `x` [ TimeSubscriptable ] - Output time series with new comments
% assigned.
%
% * `newComment` [ cellstr ] - Comments from the input time series, `x`.
%
%
% __Description__
%
% Multivariate time series have comments assigned to
% each of their columns. When assigning comments (using the syntax with two
% input arguments) you can either pass in a char (text string) or a cellstr
% (a cell array of strings). If `ColumnNames` is a char, then this same
% comment will be assigned to all of the time series columns. If
% `ColumnNames` is a cellstr, its size in the 2nd and higher dimensions
% must match the size of the time series data; the individual strings from
% `ColumnNames` will be then copied to the comments belonging to the
% individual time series columns.
%
%
% __Example__
%
%     x = Series(1:2, rand(2, 2));
%     x = comment(x, 'Comment')
%
%     x =
% 
%         Series object: 2-by-2
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
%         Series object: 2-by-2
% 
%         1: 0.28521     0.67068
%         2: 0.91586     0.78549
%         'Comment 1'    'Comment 2'
% 
%         user data: empty
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('TimeSubscriptable.comment');
    parser.addRequired('TimeSeries', @(x) isa(x, 'TimeSubscriptable'));
    parser.addOptional('NewComment', [ ], @(x) isempty(x) || ischar(x) || iscellstr(x) || isa(x, 'string') || isa(x, 'TimeSubscriptable'));
end
parser.parse(this, varargin{:});

if ismember('NewComment', parser.UsingDefaults)
    action = 'get';
else
    action = 'set';
    newComment = parser.Results.NewComment;
end

%--------------------------------------------------------------------------

varargout = cell(1, 1);

% __Get Comments__
if isequal(action, 'get')
    varargout{1} = this.Comment;
    return
end

% __Set Comments__
if isa(newComment, 'TimeSubscriptable')
    newComment = newComment.Comment;
end
this.Comment = newComment;
varargout{1} = this;

end%

