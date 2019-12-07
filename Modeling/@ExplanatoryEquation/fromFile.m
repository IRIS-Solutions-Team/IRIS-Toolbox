function this = fromFile(sourceFiles, varargin)
% fromFile  Create an array of ExplanatoryEquation objects from a source (text) file (or files)
%{
% ## Syntax ##
%
%
%    xq = ExplanatoryEquation.fromFile(sourceFiles, ...)
%
%
% ## Input Arguments ##
%
%
% __`sourceFiles`__ [ char | string | cellstr ]
% >
% The name of a source file or files from which the ExplanatoryEquation
% objects will be created.
%
%
% ## Output Arguments ##
%
%
% __`xq`__ [ ExplanatoryEquation ]
% >
% A new ExplanatoryEquation object or an array of objects created from the
% specification in the `sourceFiles`.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==1 && isequal(sourceFiles, '--test')
    this = functiontests({ 
        @singleSourceFileTest
    });
    return
end
%)


persistent pp
if isempty(pp)
    pp = extend.InputParser('ExplanatoryEquation.fromFile');
    pp.KeepUnmatched = true;
    addRequired(pp, 'sourceFiles', @(x) validate.list(x) || isa(x, 'model.File'));
end
parse(pp, sourceFiles);

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
    [ code, fileName, ...
        export__, ctrlParameters, ...
        comment, substitutions ] =  parser.Preparser.parse(sourceFiles, [ ], varargin{:});
end

%
% Split code into individual equations
%
code = string(code);
code = split(code, ";");
code = regexprep(code, "\s+", "");
code = cellstr(code);
code(cellfun('isempty', code)) = [ ];

%
% Build array of ExplanatoryEquation objects
%
this = ExplanatoryEquation.fromString(code{:});

%
% Fill in parse time information
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
    this(i) = this__;
end

if ~isempty(export__)
    export(export__);
end

end%




%
% Unit Tests 
%
%(
function singleSourceFileTest(testCase)
    f = model.File( );
    f.FileName = 'test.model';
    f.Code = [
        "%% Model"
        "!for ? = <list> !do"
        "  % Country specific equation"
        "  x_? = @ + @*x_?{-1} - @*y + y*z;"
        "!end"
    ];
    control = struct( );
    control.list = ["AA", "BB", "CC"];
    act = ExplanatoryEquation.fromFile(f, "Assign=", control);
    for i = 1 : numel(control.list)
        exp = ExplanatoryEquation( );
        s = control.list(i);
        exp.VariableNames = ["x_"+s, "y", "z"];
        exp.FileName = string(f.FileName);
        exp.InputString = "x_"+s+"=@+@*x_"+s+"{-1}-@*y+y*z";
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
%)

