function varargout = dbsearchuserdata(d,varargin)
% dbsearchuserdata  Search database to find tseries by matching the content of their userdata fields.
%
% Syntax
% =======
%
%     [List,SubD] = dbsearchuserdata(D,Field1,Regexp1,Field2,Regexp2,...)
%     [List,SubD] = dbsearchuserdata(D,Flag,Field1,Regexp1,Field2,Regexp2,...)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database whose tseries fields will be searched.
%
% * `Flag` [ `'-all'` | `'-any'` ] - Specifies if all conditions or any
% condition must be met for the series to pass the test; if not specified,
% `'-all'` is assumed.
%
% * `Field1`, `Field2`, ... [ char ] - Names of fields in the userdata
% struct.
%
% * `Regexp1`, `Regexp2`, ... [ char ] - Regular expressions against which
% the respective userdata fields will be matched.
%
% Output arguments
% =================
%
% * `List` [ cellstr ] - Names of tseries that pass the test.
%
% * `Subd` [ struct ] - Sub-database with only those tseries that pass
% the test.
%
% Description
% ============
%
% For a successful match, the userdata must be a struct, and the tested
% fields must be text strings.
%
% Use an equal sign, `=`, after the name of the userdata fields in
% `Field1`, `Field2`, etc. to request a case-insensitive match, and an
% equal-shart sign, `=#`, to indiciate a case-sensitive match.
%
% Example
% ========
%
%     [list,dd] = dbsearchuserdata(d,'.DESC=','Exchange rate','.SOURCE=#','IMF');
%
% Each individual tseries object in the database `D` will be tested for two
% conditions:
%
% * whether its user data is a struct including a field named `DESC`, and
% the field contains a string `'Exchange rate'` in it (case insensitive,
% e.g. `'eXcHaNgE rAtE'` will also be matched);
%
% * whether its user data is a struct including a field named `SOURCE`, and
% the field contains a string `'IMF'` in it (case sensitive, e.g. `'Imf'`
% will not be matched).
%
% All tseries object that pass both of these conditions are returned in the
% `List` and the output database `D`.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

func = @(x) all(x);
if ~isempty(varargin)
    if (isequal(varargin{1},'-all') || isequal(varargin{1},'-any'))
        func = mosw.str2func(['@',varargin{1}(2:end)]);
        varargin(1) = [ ];
    end
end

doTest( );

% Output arguments.
varargout{1} = list;
if nargout > 1
    varargout{2} = d * list;
end

% Nested functions.

%**************************************************************************
    function doTest( )
        list = fieldnames(d).';
        nList = length(list);
        
        testField = { };
        testValue = { };
        testFunc = { };
        doPrepTests( );
        nTest = length(testField);
        
        matched = false(1,nList);
        for i = 1 : nList
            name = list{i};
            if isa(d.(name),'tseries')
                x = userdata(d.(name));
                if ~isstruct(x)
                    continue
                end
                doEvalTests( );
            end
        end
        list = list(matched);
        
        function doPrepTests( )
            varargin(1:2:end) = strtrim(varargin(1:2:end));
            for ii = 1 : 2 : length(varargin)
                if isempty(varargin{ii}) || isempty(varargin{ii+1})
                    continue
                end
                testField{end+1} = varargin{ii}; %#ok<AGROW>
                testValue{end+1} = varargin{ii+1}; %#ok<AGROW>
                testFunc{end+1} = @regexpi; %#ok<AGROW>
                if ~isempty(testField{end}) && testField{end}(end) == '#'
                    testField{end}(end) = '';
                    testFunc{end} = @regexp;
                end
                if ~isempty(testField{end}) && testField{end}(end) == '='
                    testField{end}(end) = '';
                end
                if ~isempty(testField{end}) && testField{end}(1) == '.'
                    testField{end}(1) = '';
                end
            end
        end % doPrepTests( ).

        function doEvalTests( )
            xList = cell(1,0);
            if isstruct(x)
                xList = fieldnames(x);
            end
            xMatched = false(1,nTest);
            for ii = 1 : nTest
                inx = strcmp(testField{ii},xList);
                if ~any(inx)
                    xMatched(ii) = false;
                    continue
                end
                if isempty(testValue{ii})
                    xMatched(ii) = true;
                    continue
                end
                xValue = x.(xList{inx});
                if ~ischar(xValue)
                    continue
                end
                xMatched(ii) = ...
                    ~isempty(testFunc{ii}(xValue,testValue{ii},'once'));
            end
            matched(i) = func(xMatched);
        end
        % doEvalTests( ).
        
    end % doTest( ).

end
