% fromFile  Create an array of Explanatory objects from a source (text) file (or files)
%{
% Syntax
%--------------------------------------------------------------------------
%
%
%    xq = Explanatory.fromFile(sourceFile, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`sourceFile`__ [ string ]
%
%     The name of a source file or multiple source files from which a new
%     Explanatory objects will be created.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`xq`__ [ Explanatory ]
%
%     A new Explanatory object or an array of objects created from the
%     specification in the `sourceFile`.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% ### Basic Use Case ###
%
%
% Write a text file describing the equations, using possibly also the IRIS
% preparser control structures, and run `Explanatory.fromFile(...)`
% to create an array of `Explanatory` objects, one for each
% equation. The `Explanatory` array can be then estimated (equation
% by equation) or simulated.
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function this = fromFile(sourceFiles, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('Explanatory.fromFile');
    pp.KeepUnmatched = true;
    addRequired(pp, 'sourceFiles', @(x) validate.list(x) || isa(x, 'ModelSource'));
    addParameter(pp, {'Assigned', 'Assign'}, struct([ ]), @(x) isempty(x) || isstruct(x));
    addParameter(pp, 'Preparser', cell.empty(1, 0), @validate.nestedOptions);
end
%)
opt = parse(pp, sourceFiles, varargin{:});

%--------------------------------------------------------------------------

if isa(sourceFiles, 'ModelSource') && sourceFiles.Preparsed
    %
    % Model file already preparsed
    %
    fileName = join(string(sourceFiles.FileName), " & ");
    code = sourceFiles.Code;
    export__ = [ ];
    comment = [ ];
    substitutions = [ ];
else
    %
    % Run the preparser
    %
    if ~isempty(opt.Assigned)
        opt.Preparser = [opt.Preparser, {'Assigned', opt.Assigned}];
    end
    opt.Preparser = [{"AngleBrackets", false}, opt.Preparser, {"Skip", "Pseudofunc"}]; % [^1] [^2]
    [code, fileName, export__, ~, comment, substitutions] = ...
        parser.Preparser.parse(sourceFiles, [ ], opt.Preparser{:});
    % [^1]: Disable AngleBrackets by default for Explanatory objects
    % because < and > can be used in RHS expressions
    % [^2]: Do not preparse pseudofunctions here; these will be preparsed
    % in Explanatory.fromString
end

%
% Split code into individual equations, resolve !equations(:attribute)
%
[equations, attributes, controlNames] = Explanatory.postparse(code);


%
% Build array of Explanatory objects
%
this = Explanatory.fromString( ...
    equations, pp.UnmatchedInCell{:} ...
    , 'ControlNames', controlNames ...
);

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

end%




%
% Unit Tests 
%
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/fromFileUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test Single Source File
    f = ModelSource( );
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
    act = Explanatory.fromFile(f, 'Preparser', {'Assign', control});
    for i = 1 : numel(control.list)
        exd = Explanatory( );
        s = control.list(i);
        exd = setp(exd, "LinearStatus", true);
        exd = setp(exd, 'VariableNames', ["x_"+s, "y", "z"]);
        exd = setp(exd, 'FileName', string(f.FileName));
        exd = setp(exd, 'InputString', "x_"+s+"=@+@*x_"+s+"{-1}-@*y+y*z;");
        exd = setp(exd, 'Comment', "Model");
        exd = defineDependentTerm(exd, "x_"+s);
        exd = addExplanatoryTerm(exd, NaN, "1");
        exd = addExplanatoryTerm(exd, NaN, "x_"+s+"{-1}");
        exd = addExplanatoryTerm(exd, NaN, "-y");
        exd = addExplanatoryTerm(exd, 1, "y*z");
        exd = seal(exd);
        %
        assertEqual(testCase, act(i).ExplanatoryTerms, exd.ExplanatoryTerms);
        %
        exd_struct = struct(exd);
        act_struct = struct(act(i));
        assertEqual(testCase, sort(fieldnames(exd_struct)), sort(fieldnames(act_struct)));
        for n = keys(exd_struct)
            if isa(exd_struct.(n), 'function_handle')
                assertEqual(testCase, char(exd_struct.(n)), char(act_struct.(n)));
            else
                assertEqual(testCase, exd_struct.(n), act_struct.(n));
            end
        end
    end


%% Test Source File with Comments
    f = ModelSource( );
    f.FileName = 'test.model';
    f.Code = [
        " 'aaa' a = a{-1};"
        " 'bbb' b = b{-1};"
        " c = c{-1};"
        " 'ddd' d = d{-1};"
    ];
    act = Explanatory.fromFile(f);
    exp_LhsName = ["a", "b", "c", "d"];
    assertEqual(testCase, [act.LhsName], exp_LhsName);
    exp_Label = ["aaa", "bbb", "", "ddd"];
    assertEqual(testCase, [act.Label], exp_Label);


%% Test Source File with Empty Equations
    f = ModelSource( );
    f.FileName = 'test.model';
    f.Code = [
        " 'aaa' a = a{-1};"
        "'bbb' b = b{-1}; :empty;"
        " c = c{-1};"
        " 'ddd' d = d{-1}; ; :xxx"
    ];
    %
    state = warning('query');
    warning('off');
    act = Explanatory.fromFile(f);
    warning(state);
    %
    exp_LhsName = ["a", "b", "c", "d"];
    assertEqual(testCase, [act.LhsName], exp_LhsName);
    exp_Label = ["aaa", "bbb", "", "ddd"];
    assertEqual(testCase, [act.Label], exp_Label);
    for i = 1 : numel(act)
        assertEqual(testCase, act(i).Attributes, string.empty(1, 0));
    end



%% Test Source File with Attributes
    f = ModelSource( );
    f.FileName = 'test.model';
    f.Code = [
        ":first 'aaa' a = a{-1};"
        "'bbb' b = b{-1};"
        ":second :first c = c{-1};"
        ":first :last 'ddd' d = d{-1};"
    ];
    act = Explanatory.fromFile(f);
    exp_Attributes = {
        ":first"
        string.empty(1, 0)
        [":second" ":first"]
        [":first" ":last"]
    };
    for i = 1 : 4
        assertEqual(testCase, act(i).Attributes, exp_Attributes{i});
    end


%% Test Preparser For If
    f1 = ModelSource( );
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
    f2 = ModelSource( );
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
    act1 = Explanatory.fromFile(f1, 'Preparser', {'Assign', control});
    act2 = Explanatory.fromFile(f2, 'Preparser', {'Assign', control});
    for i = 1 : numel(control.list)
        assertEqual(testCase, act1(i).LhsName, "x_"+control.list(i));
    end
    assertEqual( ...
        testCase, ...
        func2str(act1(1).ExplanatoryTerms.Expression), ...
        '@(x,e,p,t,v,controls__)x(2,t,v).*x(3,t,v)+x(4,t,v).*x(5,t,v)' ...
    );
    %
    act1_struct = struct(act1);
    act2_struct = struct(act2);
    assertEqual(testCase, sort(fieldnames(act1_struct)), sort(fieldnames(act2_struct)));
    for n = keys(act1_struct)
        if isa(act1_struct.(n), 'function_handle')
            assertEqual(testCase, char(act1_struct.(n)), char(act2_struct.(n)));
        else
            assertEqual(testCase, act1_struct.(n), act2_struct.(n));
        end
    end


%% Test Preparser Switch
    f1 = ModelSource( );
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
        '@(x,e,p,t,v,controls__)0.8.*x(1,t-1,v)'
        '@(x,e,p,t,v,controls__)sqrt(x(2,t,v))'
        '@(x,e,p,t,v,controls__)x(2,t,v)+x(3,t,v)'
        '@(x,e,p,t,v,controls__)0'
    };
    list = ["AA", "BB", "CC", "DD"];
    for i = 1 : numel(list)
        control.country = list(i);
        act = Explanatory.fromFile(f1, 'Preparser', {'Assign', control});
        assertEqual(testCase, func2str(act.ExplanatoryTerms.Expression), exp_Expression{i});
    end


%% Test Equations with Attributes
    f = ModelSource( );
    f.FileName = "test.eqtn";
    f.Code = [
        "!equations(:aa, :bb)"
        ":1 a=a{-1}; :2 b=b{-1};"
        ":3 c=c{-1};"
        "!equations :4 d=d{-1};"
        "!equations   (:cc)"
        ":5 e=e{-1};"
    ];
    act = Explanatory.fromFile(f);
    exp_Attributes = {
        [":aa", ":bb", ":1"]
        [":aa", ":bb", ":2"]
        [":aa", ":bb", ":3"]
        [":4"]
        [":cc", ":5"]
    };
    assertEqual(testCase, reshape({act.Attributes}, [ ], 1), exp_Attributes);

##### SOURCE END #####
%}

