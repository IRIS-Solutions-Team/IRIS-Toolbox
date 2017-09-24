% rpteq  Reporting Equations (rpteq Objects).
%
% Reporting equations (rpteq) objects are systems of equations evaluated
% successively (i.e. not simultaneously) equation by equation, period by
% period.
%
% There are three basic ways to create
% reporting equations objects:
%
% * in the [`!reporting_equations`](modellang/reportingequations)
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
% * [`rpteq`](rpteq/rpteq) - New reporting equations (rpteq) object.
%
%
% __Evaluating Reporting Equations__
%
% * [`run`](rpteq/run) - Evaluate reporting equations (rpteq) object.
%
%
% __Evaluating Reporting Equations from Within Model Object__
%
% * [`reporting`](model/reporting) - Evaluate reporting equations from within model object.
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

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
            % -Copyright (c) 2007-2017 IRIS Solutions Team.
            
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
                inp = varargin{1};
                varargin(1) = [ ];
                [opt, varargin] = passvalopt('rpteq.rpteq', varargin{:});
                if ~isstruct(opt.Assign)
                    opt.Assign = struct( );
                end
                for iArg = 1 : 2 : length(varargin)
                    name = varargin{iArg};
                    value = varargin{iArg+1};
                    opt.Assign.(name) = value;
                end
                % Tell apart equations from file names.
                if ischar(inp)
                    inp = { inp };
                end
                ixFName = cellfun(@isempty, strfind(inp, '='));
                if all(ixFName)
                    % Input is file name or cellstr of file names.
                    [code, this.FileName, this.Export] = ...
                        parser.Preparser.parse(inp, [ ], ...
                        opt.Assign, '', '');
                elseif all(~ixFName)
                    % Input is equation or cellstr of equations.
                    [code, this.FileName, this.Export] = ...
                        parser.Preparser.parse([ ], inp, ...
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
                [~, eqn, euc] = parse(the, opt);
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
