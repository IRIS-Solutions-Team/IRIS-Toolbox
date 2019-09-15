function varargout = eval(d, varargin)
% eval  Evaluate expressions in databank workspace
%{
% ## Syntax ##
%
%     [output, output, ...] = databank.eval(inputDatabank, expression, expression, ...)
%
%
% ## Input Arguments ##
%
% __`inputDatabank`__ [ struct | Dictionary ] -
% Input databank whose fields constitute a workspace in which the
% expressions will be evaluated.%
%
% __`expression`__ [ char | string ] -
% Text string with an expression that will be evaluated in the workspace
% consisting of the `inputDatabank` fields.
%
%
% ## Output Arguments ##
%
% __output__ [ * ] -
% Result of the `expression` evaluated in the `inputDatabank` workspace.
%
%
% ## Description ##
%
% Any names, including dot-separated composite names, not immediately
% followed by an opening parenthesis (round bracket), are treated as
% `inputDatabank` fields. Dot=separated composite names are therefore
% considered to be fields of databanks nested withing the `inputDatabank`.
%
% Any names, including dot-separated composite names, immediately followed
% by an opening parenthesis (round bracket), are considered calls to
% functions, and not treated as `inputDatabank` fields.
%
% To include round-bracket references to `inputDatabank` fields (such as
% references to elements of arrays), include an extra space between the
% name and the opening parenthesis.
%
%
% ## Example ##
%
%     >> d = struct( );
%     >> d.aaa = [1, 2, 3];
%     >> databank.eval('10*aaa(2)')
%
% will fail with a Matlab error unless there is function named `aaa`
% existing in the current workspace. This is because `aaa(2)` is considered
% to be a call to a function named `aaa`, and not a reference to the field
% existing in the databank `d`.
%
% To refer the second element of the field `aaa`, include an extra space between `aaa` and `(` 
%
%     >> databank.eval('10*aaa (2)')
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.eval');
    parser.addRequired('Database', @validate.databank);
    parser.addRequired('Expression', @(x) all(cellfun(@(y) ischar(y) || isa(y, 'string'), x)));
end
parse(parser, d, varargin);

%--------------------------------------------------------------------------

expressions = herePreprocess(expressions);
varargout = cell(size(varargin));
for i = 1 : numel(varargout)
    varargout{i} = hereProtectedEval(d, expressions{i});
end

end%


%
% Local Functions
%


function varargout = hereProtectedEval(d, varargin)
    varargout{1} = eval(varargin{1});
end%




function expressions = herePreprocess(expressions)
    expressions = cellstr(varargin);
    expressions = strtrim(expressions);
    expressions = regexprep(expressions, ';$', '');
    expressions = regexprep(expressions, '=[ ]*#', '=');
    expressions = regexprep(expressions, '=(.*)', '-($1)', 'once');
    
    %
    % Replace any composite name with dot-separated parts not preceded by a
    % dot and not immmediately followed by a dot or an opening parenthesis
    % with a databank reference
    %
    % Anything immediately followed by an opening parenthesis is considered
    % a call to a function; to use a array reference, include a space
    % between the name of the array (a databank field) and the opening
    % parenthesis
    %
    expressions = regexprep(expressions, '(?<!\.)((\<[A-Za-z]\w*\>)(\.\<[A-Za-z]\w*\>)*)(?![\.\(])', '?.$0');
    expressions = strrep(expressions, '?.', 'd.');
end%

