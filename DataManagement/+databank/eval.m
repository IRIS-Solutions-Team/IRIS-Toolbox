function varargout = eval(inputDb, varargin)
% eval  Evaluate expressions in databank workspace
%{
% Syntax
%--------------------------------------------------------------------------
%
%     [output, output, ...] = databank.eval(inputDatabank, expression, expression, ...)
%     outputs = databank.eval(inputDatabank, expressions)
%     outputDatabank = databank.eval(inputDatabank, expressionsDatabank)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`inputDatabank`__ [ struct | Dictionary ] -
% Input databank whose fields constitute a workspace in which the
% expressions will be evaluated.%
%
%
% __`expression`__ [ char | string ] -
% Text string with an expression that will be evaluated in the workspace
% consisting of the `inputDatabank` fields.
%
%
% __`expressions`__ [ cellstr | string ] -
% Cell array of char vectors or string array (more than one element) with
% expressions that will be evaluated in the workspace consisting of the
% `inputDatabank` fields.
%
%
% __`expressionsDatabank`__ [ struct | Dictionary ]
% > Databank whose fields contain the expressions that are to be evaluated.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`output`__ [ * ] -
% Result of the `expression` evaluated in the `inputDatabank` workspace.
%
%
% __`outputs`__ [ cell ] -
% Results of the `expressions` evaluated in the `inputDatabank` workspace.
%
%
% __`outputDatabank`__ [ struct | Dictionary ]
% > Output databank with the results of the expressions evaluated in the
% `inputDatabank` workspace.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Any names, including dot-separated composite names, not immediately
% followed by an opening parenthesis (round bracket), are treated as
% `inputDatabank` fields. Dot=separated composite names are therefore
% considered to be fields of databanks nested withing the `inputDatabank`.
%
%
% Any names, including dot-separated composite names, immediately followed
% by an opening parenthesis (round bracket), are considered calls to
% functions, and not treated as `inputDatabank` fields.
%
%
% To include round-bracket references to `inputDatabank` fields (such as
% references to elements of arrays), include an extra space between the
% name and the opening parenthesis.
%
%
% Example
%--------------------------------------------------------------------------
%
%
%     >> d = struct( );
%     >> d.aaa = [1, 2, 3];
%     >> databank.eval('10*aaa(2)')
%
%
% will fail with a Matlab error unless there is function named `aaa`
% existing in the current workspace. This is because `aaa(2)` is considered
% to be a call to a function named `aaa`, and not a reference to the field
% existing in the databank `d`.
%
%
% To refer the second element of the field `aaa`, include an extra space between `aaa` and `(` 
%
%
%     >> databank.eval('10*aaa (2)')
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.eval');
    addRequired(pp, 'databank', @validate.databank);
    addRequired(pp, 'expressions', @validateExpressions);
end
parse(pp, inputDb, varargin);

%--------------------------------------------------------------------------

expressionsInDatabank = isscalar(varargin) && validate.databank(varargin{1});
needsCollapseOutput = ...
    isscalar(varargin) && (iscell(varargin{1}) || (isa(varargin{1}, 'string') && numel(varargin{1})>1));

if expressionsInDatabank
    outputDatabank = varargin{1};
    expressions = struct2cell(varargin{1});
elseif needsCollapseOutput
    if iscell(varargin{1})
        expressions = varargin{1};
    else
        expressions = cellstr(varargin{1});
    end
    sizeExpressions = size(expressions);
else
    expressions = cellstr(varargin);
end

inputExpressions = expressions;
inxToEval = cellfun('isclass', expressions, 'char');
expressions(inxToEval) = herePreprocess(inputDb, expressions(inxToEval));
inxNaN = false(size(expressions));
for i = find(transpose(inxToEval(:)))
    expressions{i} = hereProtectedEval(inputDb, expressions{i});
    inxNaN = isequaln(expressions{i}, NaN);
end

if expressionsInDatabank
    list = reshape(fieldnames(outputDatabank), 1, [ ]);
    for i = 1 : numel(list)
        outputDatabank.(list{i}) = expressions{i};
    end
    varargout{1} = outputDatabank;
elseif needsCollapseOutput
    varargout{1} = expressions;
else
    varargout = expressions;
end

if any(inxNaN)
    thisWarning = [
        "Databank:EvaluatesToNaN"
        "This expression evaluates to a scalar NaN in databank.eval( ): %s "
    ];
    throw(exception.Base(thisWarning, 'warning'), inputExpressions{inxNaN});
end

end%


%
% Local Functions
%


function varargout = hereProtectedEval(inputDb, varargin)
    varargout{1} = eval(varargin{1}, 'NaN');
end%




function expressions = herePreprocess(inputDb, expressions)
    expressions = strtrim(expressions);
    expressions = regexprep(expressions, ';$', '');
    expressions = regexprep(expressions, '=[ ]*#', '=');
    expressions = regexprep(expressions, ':[ ]*=', '=');
    expressions = regexprep(expressions, '=(.*)', '-($1)', 'once');
    
    replaceFunc = @replace;
    expressions = regexprep( ...
        expressions ...
        , '(?<![\.''"])(\<[A-Za-z]\w*\>)(\.\<[A-Za-z]\w*\>)*' ...
        , '${replaceFunc($0, $1)}' ...
    );

    expressions = strrep(expressions, '?.', 'inputDb.');

    return
        
        function c = replace(c, c1)
            if isstruct(inputDb) 
                if isfield(inputDb, c1)
                    c = ['?.', char(c)];
                end
            elseif isa(inputDb, 'Dictionary')
                if isKey(inputDb, c)
                    c = "?.(""" + string(c) + """)";
                end
            end
        end%
end%





function flag = validateExpressions(input)
    if isscalar(input) && validate.databank(input{1}) && isscalar(input{1})
        flag = true;
        return
    end
    if all(cellfun(@validate.stringScalar, input))
        flag = true;
        return
    end
    if numel(input)==1 && (iscell(input{1}) || isa(input{1}, 'string'))
        flag = true;
        return
    end
    flag = false;
end%

