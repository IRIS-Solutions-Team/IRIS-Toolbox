function varargout = dbeval(d, varargin)
% dbeval  Evaluate expression in specified database.
%
% Syntax
% =======
%
%     [Value1, Value2, ...] = dbeval(D, Exn1, Exn2, ...)
%     [Value1, Value2, ...] = dbeval(M, Exn1, Exn2, ...)
%
%
% Syntax with steady-state references
% ====================================
%
%     [Value1, Value2, ...] = dbeval(D, Steady, Exn1, Exn2, ...)
%
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database within which the expressions will be
% evaluated.
%
% * `M` [ model ] - Model object whose steady-state database will be used
% to evaluate the expression.
%
% * `Exn1`, `Exn2`, ... [ char ] - Expreessions that will be evaluated
% within the context of the input database.
%
% * `Steady` [ struct | model ] - Database or model object from which
% values will be taken to replace steady-state references in expressions.
%
%
% Output arguments
% =================
%
% * `Value1`, `Value2`, ... [ ... ] - Resulting values.
%
%
% Description
% ============
%
%
% Example
% ========
%
% Create a database with two fields and one subdatabase with one field,
%
%     d = struct( );
%     d.a = 1;
%     d.b = 2;
%     d.dd = struct( );
%     d.dd.c = 3;
%     display(d)
%     d =
%        a: 1
%        b: 2
%        c: [1x1 struct]
%
% Use the `dbeval` function to evaluate an expression within the database
%
%     dbeval(d, 'a+b+dd.c')
%     ans =
%           7
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ~isempty(varargin) && (isstruct(varargin{1}) || isa(varargin{1}, 'model'))
    ss = varargin{1};
    varargin(1) = [ ];
else
    ss = struct([ ]);
end

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('D', @(x) isstruct(x) || isa(x, 'model'));
pp.addRequired('Steady', @(x) isstruct(x) || isa(x, 'model'));
pp.addRequired('Exn', @(x) isempty(x) || iscellstr(x{1}) || iscellstr(x));
pp.parse(d, ss, varargin);

if isempty(varargin)
    varargout = { };
    return
elseif iscellstr(varargin{1})
    exn = varargin{1};
    isMultiple = false;
else
    exn = varargin;
    isMultiple = true;
end

if isa(d, 'model')
    d = get(d, 'steadyLevel');
end

if isa(ss, 'model')
    ss = get(ss, 'steadyLevel');
end

%--------------------------------------------------------------------------

nExn = numel(exn);
exn = strtrim(exn);

% Remove backtick-type marks.
exn = regexprep(exn, '`\w+', '');

list1 = fieldnames(d).';
list2 = fieldnames(ss).';
prefix1 = [char(1), '.'];
prefix2 = [char(2), '.'];
for i = 1 : length(list2)
    exn = regexprep(...
        exn, ...
        ['&\<' , list2{i}, '\>'], ...
        [prefix2, list2{i}] ...
        );
end
for i = 1 : length(list1)
    exn = regexprep( ...
        exn, ...
        ['(?<!\.)\<' , list1{i}, '\>'], ...
        [prefix1, list1{i}] ...
        );
end
exn = strrep(exn, prefix1, 'd.');
exn = strrep(exn, prefix2, 'ss.');

% Replace all possible assignments and equal signs used in IRIS codes.
% Non-linear simulation earmarks.
replaceEqualSigns( );

% Convert x=y and x+=y into x-(y) so that we can evaluate LHS minus RHS,
% and add semicolons.
handleLhsRhs( );

varargout = cell(size(exn));
for i = 1 : nExn
    try
        varargout{i} = eval(exn{i});
    catch %#ok<CTCH>
        varargout{i} = NaN;
    end
end

if ~isMultiple
    varargout{1} = varargout;
    varargout(2:end) = [ ];
end

return




    function replaceEqualSigns( )
        % NB: strrep is much faster than regexprep.
        exn = strrep(exn, '==' , '=');
        exn = strrep(exn, '=#' , '=');
        % Dtrend equations.
        exn = strrep(exn, '+=' , '=');
        exn = strrep(exn, '*=' , '=');
        % Identities.
        exn = strrep(exn, ':=' , '=');
        % Cut off steady part after the first occurrence of !!.
        pos = strfind(exn, '!!');
        ixEmpty = ~cellfun(@isempty, pos);
        if any(ixEmpty)
            exn(~ixEmpty) = regexprep(exn(~ixEmpty), '!![^;]*', '');
        end
    end




    function handleLhsRhs( )
        % NB: strrep is much faster than regexprep.        
        for ii = 1 : nExn
            c = exn{ii};
            posEqualSign = strfind(c, '=');
            if length(posEqualSign)==1
                % Remove trailing semicolons before combining LHS and RHS.
                while ~isempty(c) && c(end)==';'
                    c(end) = '';
                end
                c = [c(1:posEqualSign-1), '-(' , c(posEqualSign+1:end), ');'];
            elseif isempty(c) || c(end)~=';'
                % Add semicolon if needed.
                c = [c, ';']; %#ok<AGROW>
            end
            exn{ii} = c;
        end
    end
end
