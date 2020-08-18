classdef Equation < model.component.Insertable
    properties
        Input = cell.empty(1, 0)     % User input equations
        Type = int8.empty(1, 0)      % Equation type
        Label = cell.empty(1, 0)     % User escription attached to equation
        Alias = cell.empty(1, 0)     % LaTeX representation of equation
        Dynamic = cell.empty(1, 0)   % Parsed dynamic equations
        Steady = cell.empty(1, 0)    % Parsed steady equations
        IxHash = logical.empty(1, 0) % True for hash-signed equations
    end
    
    
    properties (Constant, Hidden)
        TYPE_ORDER = int8([1, 2, 3, 4, 5, 6]);
    end


    properties (Dependent)
        InxOfHashEquations
        NumOfHashEquations
    end


    methods
        varargout = equationStartsWith(varargin)
        varargout = getLabelOrInput(varargin)
        varargout = implementDisp(varargin)
        varargout = implementGet(varargin)
        varargout = testCompatible(varargin)

        function n = length(this)
            n = length(this.Input);
        end%

        function n = numel(this)
            n = numel(this.Input);
        end%

        varargout = postparse(varargin)
        varargout = readEquations(varargin)
        varargout = readDtrends(varargin)
        varargout = readRevisions(varargin)
        varargout = saveObject(varargin)
        varargout = selectType(varargin)
        varargout = size(varargin)
    end


    methods
        function value = get.InxOfHashEquations(this)
            value = this.IxHash;
        end%


        function value = get.NumOfHashEquations(this)
            value = nnz(this.IxHash);
        end%
    end
    
    
    methods (Static)
        varargout = extractInput(varargin)
        varargout = loadObject(varargin)


        function this = fromInput(input)
            this.Input = cellstr(input);
            numEquations = numel(this.Input);
            this.Type = repmat(int8(0), 1, numEquations);
            this.Label = repmat({''}, 1, numEquations);
            this.Alias = repmat({''}, 1, numEquations);
            this.Dynamic = cell(1, numEquations);
            this.Steady = cell(1, numEquations);
            this.IxHash = false(1, numEquations);
        end%
    end
end
