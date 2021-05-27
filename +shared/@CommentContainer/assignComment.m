function this = assignComment(this, newComment)

% >=R2019b
%{
arguments
    this shared.CommentContainer
    newComment (1, 1) string
end
%}
% >=R2019b

% <=R2019a
%(
persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addRequired(pp, 'newComment', @(x) ischar(x) || (iscellstr(x) && isscalar(x)) || (isstring(x) || isscalar(x)));
end
parse(pp, newComment);
%)
% <=R2019a

newComment = string(newComment);
if isempty(newComment) || all(strlength(newComment)==0)
    newComment = "";
end
this.Comment = newComment;

end%

