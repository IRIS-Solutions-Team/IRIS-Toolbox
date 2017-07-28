function This = comment(This,varargin)
% comment  Get or set user comments in a tseries object.
%
%
% Syntax for getting user comments
% =================================
%
%     Cmt = comment(X)
%
%
% Syntax for assigning user comments
% ===================================
%
%     X = comment(X,Cmt)
%     X = comment(X,Y)
%
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Time series.
%
% * `Cmt` [ char | cellstr ] - Comment(s) that will be assigned to each
% column of the input time series, `X`.
%
% * `Y` [ tseries ] - Time series whose comment(s) will be assigned to the
% input time series, `X`.
%
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output time series with new comments.
%
% * `Cmt` [ cellstr ] - Comments from the input time series.
%
%
% Description
% ============
%
% Multivariate time series (i.e. tseries objects) have comments assigned to
% each of their columns. When assigning comments (using the syntax with two
% input arguments) you can either pass in a char (text string) or a cellstr
% (a cell array of strings). If `Cmt` is a char, then this same comment
% will be assigned to all of the tseries columns. If `Cmt` is a cellstr,
% its size in the 2nd and higher dimensions must match the size of the
% tseries data; the individual strings from `Cmt` will be then copied to
% the comments belonging to the individual tseries columns.
%
%
% Example
% ========
%
%     x = tseries(1:2,rand(2,2));
%     x = comment(x,'Comment')
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
%     x = comment(x,{'Comment 1','Comment 2'})
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

if ~isempty(varargin)
    pp = inputParser( );
    pp.addRequired('Cmt', ...
        @(x) ischar(x) || iscellstr(x) || isa(x,'tseries'));
    pp.parse(varargin{1});
end

%--------------------------------------------------------------------------

% Get comments
%--------------
if isempty(varargin)
    This = This.Comment;
    return
end

% Set comments
%--------------
Cmt = varargin{1};
if isa(Cmt,'tseries')
    Cmt = Cmt.Comment;
end

Cmt = strrep(Cmt,'"','');
if ischar(Cmt)
    This.Comment(:) = varargin(1);
else
    s1 = size(This.data);
    s1(1) = 1;
    s2 = size(Cmt);
    if length(s1)==length(s2) && all(s1==s2)
        This.Comment = Cmt;
    elseif isequal(s2,[1,1])
        This.Comment = repmat(Cmt,[1,s1(2:end)]);
    else
        utils.error('tseries:comment', ...
            'Incorrect size of comments attempted to be assigned.');
    end
end

end
