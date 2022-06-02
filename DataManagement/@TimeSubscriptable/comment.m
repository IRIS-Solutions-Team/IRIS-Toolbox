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
% * `newComment` [ string ] - Comment(s) that will be assigned
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
%     x = comment(x, "Comment")
%
%     x =
%
%         Series object: 2-by-2
%         Class of Data: double
%
%         1: 0.28521     0.67068
%         2: 0.91586     0.78549

%         "Dates"    "Comment"    "Comment"
%
%         User data: empty
%
%     x = comment(x, ["Comment 1", "Comment 2"])
%
%     x =
%
%         Series object: 2-by-2
%         Class of Data: double
%
%         1: 0.28521     0.67068
%         2: 0.91586     0.78549
%
%         "Dates"    "Comment 1"    "Comment 2"
%
%         User Data: empty
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

% >=R2019b
%{
function varargout = comment(this, newComment)

arguments
    this TimeSubscriptable

    newComment {local_validateNewComment} = @get
end
%}
% >=R2019b


% <=R2019a
%(
function varargout = comment(this, newComment)

if nargin<2
    newComment = @get;
end
%)
% <=R2019a


if isequal(newComment, @get)

    % __Get comments__

    varargout{1} = this.Comment;

else

    % __Set comments__

    if isa(newComment, 'TimeSubscriptable')
        newComment = newComment.Comment;
    end
    sizeData = size(this.Data);
    this.Comment = strings([1, sizeData(2:end)]);
    this.Comment(:) = string(newComment);
    varargout{1} = this;

end

end%

%
% Local validators
%

function local_validateNewComment(value)
    %(
    if isequal(value, @get) || validate.text(value) || isa(value, 'TimeSubscriptable')
        return
    end
    error("Input argument must be a string, another time series, or @get.");
    %)
end%

