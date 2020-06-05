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
% -Copyright (c) 2007-2020 IRIS Solutions Team

function this = fromFile(sourceFiles, varargin)

% Parse input arguments
%(
persistent pp
if isempty(pp)
    pp = extend.InputParser('Explanatory.fromFile');
    pp.KeepUnmatched = true;
    addRequired(pp, 'sourceFiles', @(x) validate.list(x) || isa(x, 'model.File'));
    addParameter(pp, {'Assigned', 'Assign'}, struct([ ]), @(x) isempty(x) || isstruct(x));
    addParameter(pp, 'Preparser', cell.empty(1, 0), @validate.nestedOptions);
    addParameter(pp, 'InitObject', Explanatory( ), @(x) isa(x, 'Explanatory'));
end
opt = parse(pp, sourceFiles, varargin{:});
%)

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
    if ~isempty(opt.Assigned)
        opt.Preparser = [opt.Preparser, {'Assigned=', opt.Assigned}];
    end
    opt.Preparser = [{'AngleBrackets=', false}, opt.Preparser]; % [^1]
    [code, fileName, export__, ~, comment, substitutions] = ...
        parser.Preparser.parse(sourceFiles, [ ], opt.Preparser{:});
    % [^1]: Disable AngleBrackets by default for Explanatory objects
    % because < and > can be used in RHS expressions.
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
    , 'ControlNames=', controlNames ...
    , 'InitObject=', opt.InitObject ...
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
%(
