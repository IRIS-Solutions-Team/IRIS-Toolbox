
% >=R2019b
%{
function varargout = comment(this, newComment)

arguments
    this Series
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

        if isa(newComment, 'Series')
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
    if isequal(value, @get) || validate.text(value) || isa(value, 'Series')
        return
    end
    error("Input argument must be a string, another time series, or @get.");
    %)
end%

