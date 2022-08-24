% rpteq  Reporting Equations (rpteq Objects)
%
% Reporting equations (rpteq) objects are systems of equations evaluated
% successively (i.e. not simultaneously) equation by equation, period by
% period.
%
% There are three basic ways to create
% reporting equations objects:
%
% * in a [`!reporting-equations`]() section of a model file;
%
% * in a separate reporting equations file;
%
% * on the fly within an m-file or in the command window.
%
% rpteq methods:
%
%
% __Constructor__
%
%   rpteq - New reporting equations (rpteq) object
%
%
% __Evaluating Reporting Equations__
%
%   run - Evaluate reporting equations (rpteq) object
%
%
% __Evaluating Reporting Equations from Within Model Object__
%
%   reporting - Evaluate reporting equations from within model object
%
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

classdef rpteq < iris.mixin.GetterSetter ...
               & iris.mixin.UserDataContainer ...
               & iris.mixin.CommentContainer ...
               & iris.mixin.DatabankPipe

    properties
        FileName = char.empty(1, 0)
        NamesOfLhs = cell.empty(1, 0)
        NamesOfRhs = cell.empty(1, 0)
        NamesOfSteadyRef = cell.empty(1, 0)
        EqtnRhs = cell.empty(1, 0)
        NaN = double.empty(1, 0)
        UsrEqtn = cell.empty(1, 0)
        Label = cell.empty(1, 0)
        MaxSh = 0
        MinSh = 0
        Export = iris.mixin.Export.empty(1, 0)
    end


    methods
        function this = rpteq(varargin)
% rpteq  New reporting equations (rpteq) object
%
% __Syntax__
%
%     Q = rpteq(FileName)
%     Q = rpteq(Eqtn)
%
%
% __Input Arguments__
%
% * `FileName` [ char | cellstr ] - File name or cellstr array of
% file names, each a plain text file with reporting equations;
% multiple input files will be combined together.
%
% * `Eqtn` [ char | cellstr ] - Text string with an equation or cellarray
% of equations.
%
%
% __Output Arguments__
%
% * `Q` [ rpteq ] - New reporting equations object.
%
%
% __Description__
%
% Reporting equations must be written in the following form:
%
%     `LhsName = RhsExpr;`
%     `"Label" LhsName = RhsExpr;`
%
% where
%
% * `LhsName` is the name of a left-hand-side variable (with no
% lag or lead);
%
% * `RhsExpr` is an expression on the right-hand side that will be
% evaluated period by period, and assigned to the left-hand-side variable, 
% `LhsName`. The RHS expression must be ended with a semicolon.
%
% * `"Label"` is an optional label that will be used to create
% a comment in the output time series for the respective
% left-hand-side variable.
%
% * the equation must end with a semicolon.
%
%
% __Example__
%
%     q = rpteq({ ...
%         'a = c * a{-1}^0.8 * b{-1}^0.2;', ...
%         'b = sqrt(b{-1});', ...
%         })
%
%     q =
%         rpteq Object
%         Number of Equations: [2]
%         Comment: ''
%         User Data: empty
%         Export Files: [0]
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team
            
            %( Input parser
            persistent pp ppParser
            if isempty(pp) || isempty(ppParser)
                pp = extend.InputParser('@rpteq/rpteq');
                pp.KeepUnmatched = true;
                pp.PartialMatching = false;
                pp.addRequired('Input', @(x) ischar(x) || isa(x, 'string') || iscellstr(x));
                pp.addParameter({'Assigned', 'Assign'}, struct( ), @isstruct);
                pp.addParameter('saveas', char.empty(1, 0), @(x) ischar(x) || isa(x, 'string'));

                ppParser = extend.InputParser('@rpteq/rpteq');
                ppParser.KeepUnmatched = true;
                ppParser.PartialMatching = false;
                ppParser.addParameter('AutodeclareParameters', false, @(x) isequal(x, true) || isequal(x, false)); 
                ppParser.addParameter({'SteadyOnly', 'SstateOnly'}, false, @(x) isequal(x, true) || isequal(x, false));
                ppParser.addParameter({'AllowMultiple', 'Multiple'}, false, @(x) isequal(x, true) || isequal(x, false));
            end
            %)
            
            %--------------------------------------------------------------
            
            if nargin==0
                return
            end

            if isa(varargin{1}, 'model.Equation')
                % Preparsed code from model object.
                eqn = varargin{1};
                euc = varargin{2};
                this.FileName = varargin{3};
            elseif ischar(varargin{1}) || iscellstr(varargin{1})
                opt = parse(pp, varargin{:});
                input = pp.Results.Input;
                parse(ppParser, pp.UnmatchedInCell{:});
                unmatched = ppParser.UnmatchedInCell;
                if ~isstruct(opt.Assigned)
                    opt.Assigned = struct( );
                end
                for i = 1 : 2 : numel(unmatched)
                    opt.Assigned.(umatched{i}) = unmatched{i+1};
                end
                % Tell apart equations from file names
                inxFileNames = cellfun(@isempty, strfind(cellstr(input), '='));
                if all(inxFileNames)
                    % Input is file name or cellstr of file names
                    [code, this.FileName, this.Export] = ...
                        parser.Preparser.parse( ...
                            input, [ ] ...
                            , 'Assigned', opt.Assigned ...
                        );
                elseif all(~inxFileNames)
                    % Input is equation or cellstr of equations
                    [code, this.FileName, this.Export] = ...
                        parser.Preparser.parse( ...
                            [ ], input, ...
                            'Assigned', opt.Assigned ...
                        );
                else
                    thisError = [ 
                        "rpteq:Constructor"
                        "Input to rpteq constructor must be either file names or equations but not both"
                    ];
                    throw(exception.Base(thisError, 'error'));
                end
                export(this);
                % Supply the  `!reporting-equations` keyword if missing.
                if isempty(strfind(code, '!reporting-equations'))
                    code = ['!reporting-equations', newline( ), code];
                end
                % Run theparser on preparsed code
                the = parser.TheParser('rpteq', this.FileName, code, opt.Assigned);
                parserOptions = ppParser.Options;
                parserOptions.EquationSwitch = @auto;
                [~, eqn, euc] = parse(the, parserOptions);
            end
            
            % Run rpteq postparser
            this = postparse(this, eqn, euc);
        end
    end
    
    
    
    
    methods
        varargout = run(varargin)


        function export(this)
            export(this.Export);
        end%
    end
    
    
    methods (Hidden)
        function [minSh, maxSh] = getActualMinMaxShifts(this)
            minSh = this.MinSh;
            maxSh = this.MaxSh;
        end%


        varargout = checkConsistency(varargin)


        function value = countVariants(this)
            value = 1;
        end%
        

        function disp(varargin)
            implementDisp(varargin{:});
            textual.looseLine( );
        end%


        function value = nameAppendables(this)
            value = this.NamesOfLhs;
        end%


        varargout = implementGet(varargin)
    end
    
    
    methods (Access=protected, Hidden)
        implementDisp(varargin)
        varargout = postparse(varargin)
    end
end

