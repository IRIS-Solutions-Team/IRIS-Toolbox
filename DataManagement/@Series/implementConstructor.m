function this = implementConstructor(this, dates, values, comment, userData, skipInputParser)

% >=R2019b
%{
arguments
    this
    dates {validate.mustBeDate}
    values {local_validateValues}
    comment {local_validateComment}
    userData
    skipInputParser
end
skip = ~isempty(skipInputParser);
%}
% >=R2019b


% <=R2019a
%(
persistent ip
if isempty(ip)
    ip = extend.InputParser();
    ip.KeepDefaultOptions = true;

    addRequired(ip, 'Dates', @validate.date);
    addRequired(ip, 'Values', @local_validateValues);
    addRequired(ip, 'Comment', @local_validateComment);
    addRequired(ip, 'UserData');
end
skip = maybeSkip(ip, skipInputParser{:});
if ~skip
    parse(ip, dates, values, comment, userData);
end
%)
% <=R2019a


    %
    % Initialize the time series start date and data, trim data
    % array
    %
    this = init(this, dates, values);


    %
    % Populate comments for each data column
    %
    if ~skip
        this = resetComment(this);
    end
    if ~isempty(comment)
        this.Comment = comment;
    end


    %
    % Populate user data
    %
    if ~isequal(userData, [])
        this = userdata(this, userData);
    end

end%

%
% Local validators
%

function local_validateValues(x)
    %(
    if isnumeric(x) || islogical(x) || isa(x, 'function_handle') || isstring(x) || iscell(x)
        return
    end
    error("Input value must be a numeric, logical, string or cell array, or a function.");
    %)
end%


function local_validateComment(x)
    %(
    if isempty(x) || ischar(x) || iscellstr(x) || isstring(x)
        return
    end
    error("Input value must empty or a string.");
    %)
end%

