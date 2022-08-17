function varargout = eval(inputDb, varargin)

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

