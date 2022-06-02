function this = assignComment(this, newComment)

% >=R2019b
%{
arguments
    this iris.mixin.CommentContainer
    newComment (1, 1) string
end
%}
% >=R2019b


newComment = string(newComment);
if isempty(newComment) || all(strlength(newComment)==0)
    newComment = "";
end
this.Comment = newComment;

end%

