% rpteq  Reporting Equations (rpteq Objects).
%
% Reporting equations (rpteq) objects are systems of equations evaluated
% successively (i.e. not simultaneously) equation by equation, period by
% period.
%
% There are three basic ways to create
% reporting equations objects:
%
% * in the [`!reporting_equations`](irislang/reportingequations)
% section of a model file;
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
%   rpteq - New reporting equations (rpteq) object.
%
%
% __Evaluating Reporting Equations__
%
%   run - Evaluate reporting equations (rpteq) object.
%
%
% __Evaluating Reporting Equations from Within Model Object__
%
%   reporting - Evaluate reporting equations from within model object.
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

classdef rpteq < shared.GetterSetter & shared.UserDataContainer
    properties
        FileName = char.empty(1, 0)
        NameLhs = cell.empty(1, 0)
        NameRhs = cell.empty(1, 0)
        NameSteadyRef = cell.empty(1, 0)
        EqtnRhs = cell.empty(1, 0)
        NaN = double.empty(1, 0)
        UsrEqtn = cell.empty(1, 0)
        Label = cell.empty(1, 0)
        MaxSh = 0
        MinSh = 0
        Export = shared.Export.empty(1, 0)
    end
    
    
    methods
        function this = rpteq(varargin)
            % rpteq  New reporting equations (rpteq) object.
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
            %         rpteq object
            %         number of equations: [2]
            %         comment: ''
            %         user data: empty
            %         export files: [0]
            %
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2018 IRIS Solutions Team.
            
            persistent INPUT_PARSER PARSER_OPTIONS
            if isempty(INPUT_PARSER)
                INPUT_PARSER = extend.InputParser('rpteq.rpteq');
                INPUT_PARSER.KeepUnmatched = true;
                INPUT_PARSER.PartialMatching = false;
                INPUT_PARSER.addRequired('InputEquations', @(x) ischar(x) || isa(x, 'string') || iscellstr(x));
                INPUT_PARSER.addParameter('Assign', struct( ), @isstruct);
                INPUT_PARSER.addParameter('saveas', char.empty(1, 0), @(x) ischar(x) || isa(x, 'string'));
            end
            if isempty(PARSER_OPTIONS)
                PARSER_OPTIONS = extend.InputParser('model.model');
                PARSER_OPTIONS.KeepUnmatched = true;
                PARSER_OPTIONS.PartialMatching = false;
                PARSER_OPTIONS.addParameter('AutodeclareParameters', false, @(x) isequal(x, true) || isequal(x, false)); 
                PARSER_OPTIONS.addParameter({'SteadyOnly', 'SstateOnly'}, false, @(x) isequal(x, true) || isequal(x, false));
                PARSER_OPTIONS.addParameter({'AllowMultiple', 'Multiple'}, false, @(x) isequal(x, true) || isequal(x, false));
            end

            BR = sprintf('\n');
            
            %--------------------------------------------------------------
            
            if nargin==0
                return
            end

            if isa(varargin{1}, 'model.component.Equation')
                % Preparsed code from model object.
                eqn = varargin{1};
                euc = varargin{2};
                this.FileName = varargin{3};
            elseif ischar(varargin{1}) || iscellstr(varargin{1})
                INPUT_PARSER.parse(varargin{:});
                inputEquations = INPUT_PARSER.Results.InputEquations;
                opt = INPUT_PARSER.Options;
                PARSER_OPTIONS.parse(INPUT_PARSER.UnmatchedInCell{:});
                parserOpt = PARSER_OPTIONS.Options;
                unmatched = PARSER_OPTIONS.UnmatchedInCell;
                if ~isstruct(opt.Assign)
                    opt.Assign = struct( );
                end
                for i = 1 : 2 : numel(unmatched)
                    opt.Assign.(umatched{i}) = unmatched{i+1};
                end
                % Tell apart equations from file names.
                if ~iscellstr(inputEquations)
                    inputEquations = cellstr(inputEquations);
                end
                indexFileNames = cellfun(@isempty, strfind(inputEquations, '='));
                if all(indexFileNames)
                    % Input is file name or cellstr of file names.
                    [code, this.FileName, this.Export] = ...
                        parser.Preparser.parse(inputEquations, [ ], ...
                        opt.Assign, '', '');
                elseif all(~indexFileNames)
                    % Input is equation or cellstr of equations.
                    [code, this.FileName, this.Export] = ...
                        parser.Preparser.parse([ ], inputEquations, ...
                        opt.Assign, '', '');
                else
                    utils.error('rpteq:rpteq', ...
                        ['Input to rpteq( ) must be either file name(s), ', ...
                        'or equation(s), but not combination of both.']);
                end
                export(this);
                % Supply the  `!reporting_equations` keyword if missing.
                if isempty(strfind(code, '!reporting_equations'))
                    code = ['!reporting_equations', BR, code];
                end
                % Run theparser on preparsed code.
                the = parser.TheParser('rpteq', this.FileName, code, opt.Assign);
                [~, eqn, euc] = parse(the, parserOpt);
            end
            
            % Run rpteq postparser.
            this = postparse(this, eqn, euc);
        end
    end
    
    
    
    
    methods
        varargout = run(varargin)


        function export(this)
            export(this.Export);
        end
    end
    
    
    methods (Hidden)
        varargout = chkConsistency(varargin)
        varargout = disp(varargin)
        varargout = implementGet(varargin)
    end
    
    
    methods (Access=protected, Hidden)
        varargout = postparse(varargin)
    end
end
