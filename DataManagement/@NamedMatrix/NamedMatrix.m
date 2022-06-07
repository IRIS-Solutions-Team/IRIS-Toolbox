classdef NamedMatrix ...
    < namedmat

    methods
        function this = abs(this)
            rowNames = this.RowNames;
            columnNames = this.ColNames;
            this = abs@double(this);
            this = NamedMatrix(this, rowNames, columnNames);
        end%


        function this = round(this, varargin)
            rowNames = this.RowNames;
            columnNames = this.ColNames;
            this = round@double(this, varargin{:});
            this = NamedMatrix(this, rowNames, columnNames);
        end%


        function this = ctranspose(this)
            this = pageFunc(this, @ctranspose, this.ColumnNames, this.RowNames);
        end%


        function this = transpose(this)
            rowNames = this.RowNames;
            columnNames = this.ColNames;
            this = pageFunc(this, @transpose, this.ColumnNames, this.RowNames);
        end%


        function varargout = horzcat(varargin)
            [varargout{1:nargout}] = cat(2, varargin{:});
        end%


        function varargout = vertcat(varargin)
            [varargout{1:nargout}] = cat(1, varargin{:});
        end%


        function varargout = cat(n, varargin)
            for i = 1 : numel(varargin)
                varargin{i} = double(varargin{i});
            end
            [varargout{1:nargout}] = cat(n, varargin{:});
        end%


        function output = subsref(varargin)
            output = subsref@namedmat(varargin{:});
            if isa(output, 'namedmat')
                output = NamedMatrix(output);
            end
        end%
    end


    methods (Access=protected, Hidden)
        function new = pageFunc(this, func, rowNames, columnNames);
            this = double(this);
            sizeThis = size(this);
            this = this(:, :, :);
            numPages = size(this, 3);
            new = cell(1, numPages);
            for i = 1 : numPages
                new{i} = func(this(:, :, i));
            end
            new = cat(3, new{:});
            new = reshape(new, sizeThis);
            new = NamedMatrix(new, rowNames, columnNames);
        end%
    end
end

