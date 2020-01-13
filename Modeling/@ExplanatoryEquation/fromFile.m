function varargout = fromFile(sourceFiles, varargin)
% fromFile  Create an array of ExplanatoryEquation objects from a source (text) file (or files)
%{
% ## Syntax ##
%
%
%    xq = ExplanatoryEquation.fromFile(sourceFile, ...)
%
%
% ## Input Arguments ##
%
%
% __`sourceFile`__ [ char | string | cellstr ]
% >
% The name of a source file or multiple source files from which a new
% ExplanatoryEquation objects will be created.
%
%
% ## Output Arguments ##
%
%
% __`xq`__ [ ExplanatoryEquation ]
% >
% A new ExplanatoryEquation object or an array of objects created from the
% specification in the `sourceFile`.
%
%
% ## Description ##
%
%
% Write a text file describing the equations, using possibly also the IRIS
% preparser control structures, and run `ExplanatoryEquation.fromFile(...)`
% to create an array of `ExplanatoryEquation` objects, one for each
% equation. The `ExplanatoryEquation` array can be then estimated (equation
% by equation) or simulated.
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==1 && isequal(sourceFiles, '--test')
    varargout{1} = unitTests( );
    return
end
%)


persistent pp
if isempty(pp)
    pp = extend.InputParser('ExplanatoryEquation.fromFile');
    pp.KeepUnmatched = true;
    addRequired(pp, 'sourceFiles', @(x) validate.list(x) || isa(x, 'model.File'));
    addParameter(pp, 'Preparser', cell.empty(1, 0), @iscell);
end
parse(pp, sourceFiles, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

if isa(sourceFiles, 'model.File') && sourceFiles.Preparsed
    %
    % Model file already preparsed
    %
    fileName = sourceFiles.FileName;
    code = sourceFiles.Code;
    export__ = [ ];
    comment = [ ];
    substitutions = [ ];
else
    %
    % Run the preparser
    %
    [code, fileName, export__, ~, comment, substitutions] = ...
        parser.Preparser.parse(sourceFiles, [ ], opt.Preparser{:});
end

%
% Split code into individual equations, resolve !equations(:attribute)
%
[equations, attributes] = ExplanatoryEquation.postparse(code);


%
% Build array of ExplanatoryEquation objects
%
this = ExplanatoryEquation.fromString(equations, pp.UnmatchedInCell{:});


%
% Fill in parse time information * FileName * Export * Comment
%
for i = 1 : numel(this)
    this__ = this(i);
    this__.FileName = string(fileName);
    if ~isempty(export__)
        this__.Export = export__;
    end
    if ~isempty(comment)
        this__.Comment = string(comment);
    end
    if ~isempty(substitutions)
        this__.Substitutions = substitutions;
    end
    if ~isempty(attributes{i})
        this__.Attributes = [attributes{i}, this__.Attributes];
    end
    this(i) = this__;
end

%
% Export files, do only once
%
if ~isempty(export__)
    export(export__);
end


%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
varargout{1} = this;
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


end%




%
% Unit Tests 
%
%(
function tests = unitTests( )
    tests = functiontests({ 
        @singleSourceFileTest
        @sourceFileWithCommentsTest
        @sourceFileWithEmptyEquationsTest
        @sourceFileWithAttributesTest
        @preparserForIfTest
        @preparserSwitchTest
        @equationsAttributesTest
    });
    tests = reshape(tests, [ ], 1);
end%


function singleSourceFileTest(testCase)
    f = model.File( );
    f.FileName = 'test.model';
    f.Code = [
        "%% Model"
        "!for ? = $[ list ]$ !do"
        "  % Country specific equation"
        "  x_? = @ + @*x_?{-1} - @*y + y*z;"
        "!end"
    ];
    control = struct( );
    control.list = ["AA", "BB", "CC"];
    act = ExplanatoryEquation.fromFile(f, 'Preparser=', {'Assign=', control});
    for i = 1 : numel(control.list)
        exp = ExplanatoryEquation( );
        s = control.list(i);
        exp.VariableNames = ["x_"+s, "y", "z"];
        exp.FileName = string(f.FileName);
        exp.InputString = "x_"+s+"=@+@*x_"+s+"{-1}-@*y+y*z;";
        exp.Comment = "Model";
        exp = defineDependent(exp, 1);
        exp = addExplanatory(exp, "1");
        exp = addExplanatory(exp, 1, "Shift=", -1);
        exp = addExplanatory(exp, "-y");
        exp = addExplanatory(exp, "y*z", "Fixed=", 1);
        assertEqual(testCase, act(i).Explanatory, exp.Explanatory);
        assertEqual(testCase, act(i), exp);
    end
end%


function sourceFileWithCommentsTest(testCase)
    f = model.File( );
    f.FileName = 'test.model';
    f.Code = [
        " 'aaa' a = a{-1};"
        " 'bbb' b = b{-1};"
        " c = c{-1};"
        " 'ddd' d = d{-1};"
    ];
    act = ExplanatoryEquation.fromFile(f);
    exp_LhsName = ["a", "b", "c", "d"];
    assertEqual(testCase, [act.LhsName], exp_LhsName);
    exp_Label = ["aaa", "bbb", "", "ddd"];
    assertEqual(testCase, [act.Label], exp_Label);
end%


function sourceFileWithEmptyEquationsTest(testCase)
    f = model.File( );
    f.FileName = 'test.model';
    f.Code = [
        " 'aaa' a = a{-1};"
        "'bbb' b = b{-1}; :empty;"
        " c = c{-1};"
        " 'ddd' d = d{-1}; ; :xxx"
    ];

    state = warning('query');
    warning('off');
    act = ExplanatoryEquation.fromFile(f);
    warning(state);

    exp_LhsName = ["a", "b", "c", "d"];
    assertEqual(testCase, [act.LhsName], exp_LhsName);
    exp_Label = ["aaa", "bbb", "", "ddd"];
    assertEqual(testCase, [act.Label], exp_Label);
    for i = 1 : numel(act)
        assertEqual(testCase, act(i).Attributes, string.empty(1, 0));
    end
end%


function sourceFileWithAttributesTest(testCase)
    f = model.File( );
    f.FileName = 'test.model';
    f.Code = [
        ":first 'aaa' a = a{-1};"
        "'bbb' b = b{-1};"
        ":second :first c = c{-1};"
        ":first :last 'ddd' d = d{-1};"
    ];
    act = ExplanatoryEquation.fromFile(f);
    exp_Attributes = {
        ":first"
        string.empty(1, 0)
        [":second" ":first"]
        [":first" ":last"]
    };
    for i = 1 : 4
        assertEqual(testCase, act(i).Attributes, exp_Attributes{i});
    end
end%


function preparserForIfTest(testCase)
    f1 = model.File( );
    f1.FileName = 'test.model';
    f1.Code = [
        "!for ?c = $[ list ]$ !do"
        "    x_?c = "
        "    !for ?w = $[ list ]$ !do"
        "        !if ""?w""~=""?c"" "
        "            + w_?c_?w*x_?w"
        "        !end"
        "    !end"
        "    ;"
        "!end"
    ];
    f2 = model.File( );
    f2.FileName = 'test.model';
    f2.Code = [
        "!for ?c = $[ list ]$ !do"
        "    x_?c = "
        "    !for ?w = $[ setdiff(list, ""?c"") ]$ !do"
        "        !if ""?w""~=""?c"" "
        "            + w_?c_?w*x_?w"
        "        !end"
        "    !end"
        "    ;"
        "!end"
    ];
    control = struct( );
    control.list = ["AA", "BB", "CC"];
    act1 = ExplanatoryEquation.fromFile(f1, 'Preparser=', {'Assign=', control});
    act2 = ExplanatoryEquation.fromFile(f2, 'Preparser=', {'Assign=', control});
    for i = 1 : numel(control.list)
        assertEqual(testCase, act1(i).LhsName, "x_"+control.list(i));
    end
    assertEqual( ...
        testCase, ...
        func2str(act1(1).Explanatory.Expression), ...
        '@(x,t,date__)x(2,t,:).*x(3,t,:)+x(4,t,:).*x(5,t,:)' ...
    );
    assertEqual(testCase, act1, act2);
end%


function preparserSwitchTest(testCase)
    f1 = model.File( );
    f1.FileName = 'test.model';
    f1.Code = [
        "!switch country"
        "   !case ""AA"" "
        "       x = 0.8*x{-1};"
        "   !case ""BB"" "
        "       x = sqrt(y);"
        "    !case ""CC"" "
        "       x = a + b;"
        "   !otherwise"
        "       x = 0;"
        "!end"
    ];
    exp_Expression = {
        '@(x,t,date__)0.8.*x(1,t-1,:)'
        '@(x,t,date__)sqrt(x(2,t,:))'
        '@(x,t,date__)x(2,t,:)+x(3,t,:)'
        '@(x,t,date__)0'
    };
    list = ["AA", "BB", "CC", "DD"];
    for i = 1 : numel(list)
        control.country = list(i);
        act = ExplanatoryEquation.fromFile(f1, 'Preparser=', {'Assign=', control});
        assertEqual(testCase, func2str(act.Explanatory.Expression), exp_Expression{i});
    end
end%


function equationsAttributesTest(testCase)
    f = model.File( );
    f.FileName = "test.eqtn";
    f.Code = [
        "!equations(:aa, :bb)"
        ":1 a=a{-1}; :2 b=b{-1};"
        ":3 c=c{-1};"
        "!equations :4 d=d{-1};"
        "!equations(:cc)"
        ":5 e=e{-1};"
    ];
    act = ExplanatoryEquation.fromFile(f);
    exp_Attributes = {
        [":aa", ":bb", ":1"]
        [":aa", ":bb", ":2"]
        [":aa", ":bb", ":3"]
        [":4"]
        [":cc", ":5"]
    };
    assertEqual(testCase, reshape({act.Attributes}, [ ], 1), exp_Attributes);
end%
%)

