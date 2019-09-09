classdef Series < reptile.Base
    properties (Constant)
        CanBeParent = {'reptile.Axes'}
    end


    properties
        ExpressionToEval = ''
        Value = NaN
    end


    properties (Dependent)
        LegendEntries = cell.empty(1, 0)
    end


    methods
        function this = Series(varargin)
            input = char.empty(1, 0);
            if nargin>=3
                input = varargin{3};
                varargin(3) = [ ];
            end
            this = this@reptile.Base(varargin{:});
            if ischar(input)
                this.ExpressionToEval = input;
                this.Value = NaN;
            else
                this.ExpressionToEval = '';
                this.Value = input;                
            end
        end% 


        function eval(this, inputDatabank)
            if ~isempty(this.ExpressionToEval)
                this.Value = databank.eval(inputDatabank, this.ExpressionToEval);
            end
        end%


        function this = set.ExpressionToEval(this, value)
            if ischar(value) || isa(value, 'string')
                    this.ExpressionToEval = value;
                    return
            end
            error( 'reptile:Base:InvalidValueExpressionToEval', ...
                   'Invalid value assigned to ExpressionToEval' );
        end%


        function c = get.LegendEntries(this)
            base = this.Caption;
            if isempty(base)
                base = this.ExpressionToEval;
            end
            numCols = size(this.Value, 2);
            c = cell(1, numCols);
            c(:) = { base };
        end%
    end
end

