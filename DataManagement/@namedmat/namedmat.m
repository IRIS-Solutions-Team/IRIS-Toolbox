% namedmat  Matrices with Named Rows and Columns (namedmat Objects).
%
% Matrices with named rows and columns are returned as output arguments
% from several IRIS functions, such as [model/acf](model/acf),
% [model/xsf](model/xsf), or [model/fmse](model/fmse), to facilitate easy
% selection of submatrices by referrring to variable names in rows and
% columns.
%
% Namedmat methods:
%
%
% __Constructor__
%
% * [`namedmat`](namedmat/namedmat) - Create a new matrix with named rows and columns.
%
%
% __Manipulating namedmat Objects__
%
% * [`select`](namedmat/select) - Select submatrix by referring to row names and column names.
% * [`transpose`](namedmat/transpose) - Transpose each page of matrix with names rows and columns.
%
%
% __Getting Row and Column Names__
%
% * [`rownames`](namedmat/rownames) - Names of rows in namedmat object.
% * [`colnames`](namedmat/colnames) - Names of columns in namedmat object.
%
%
% __Sample Characteristics__
%
% * [`cutoff`](namedmat/cutoff] -
%
% All operators and functions available for standard Matlab matrices
% and arrays (i.e. double objects) are also available for namedmat
% objects.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

classdef namedmat < double
    properties (SetAccess = protected)
        RowNames (1, :) string = string.empty(1, 0)
        ColNames (1, :) string = string.empty(1, 0)
    end


    properties (Dependent)
        ColumnNames
    end


    methods
        function this = namedmat(X, varargin)
% namedmat  Create a new matrix with named rows and columns
%
% __Syntax__
%
%     X = namedmat(X, RowNames, ColNames)
%     X = namedmat(X, Names)
%
%
% __Input Arguments__
%
% * `X` [ numeric ] - Matrix or multidimensional array.
%
% * `RowNames` [ cellstr ] - Names for individual rows of `X`.
%
% * `ColNames` [ cellstr ] - Names for individual columns of
% `X`.
%
% * `Names` [ cellstr ] - Names for both rows and columns of
% `X`.
%
%
% __Output Arguments__
%
% * `X` [ namedmat ] - Matrix with named rows and columns.
%
%
% __Description__
%
% The namedmat objects are used by some of the IRIS functions to
% preserve the names of variables that relate to individual
% rows and columns, such as in
%
% * `acf( )`, the autocovariance and autocorrelation functions,
% * `xsf( )`, the power spectrum and spectral density functions,
% * `fmse( )`, the forecast mean square error fuctions, etc.
%
% You can use the function [`select`](namedmat/select) to
% extract submatrices by referring to a selection of names.
%
% Namedmat matrices derives from the built-in double class of
% objects, and hence you can use any operators and functions on
% them that are available for double objects.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------

            if nargin==0
                X = double.empty(0, 0);
            end
            this = this@double(X);
            this.RowNames = string.empty(1, 0);
            this.ColNames = string.empty(1, 0);
            if length(varargin)>=1
                this.RowNames = varargin{1};
            end
            if length(varargin)>=2
                this.ColNames = varargin{2};
            elseif length(varargin)==1
                this.ColNames = this.RowNames;
            end
        end%





        varargout = colnames(varargin)
        varargout = ctranspose(varargin)
        varargout = cutoff(varargin);
        varargout = horzcat(varargin)
        varargout = plot(varargin)
        varargout = rownames(varargin)
        varargout = select(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)
        varargout = table(varargin)
        varargout = transpose(varargin)
        varargout = vertcat(varargin)


        function names = setNames(this, dimension, names)
            switch dimension
                case 1
                    dimensionName = "Row";
                case 2
                    dimensionName = "Column";
            end

            numRequired = size(this, dimension);
            if isempty(names)
                names = compose(dimensionName + "_%g", 1:numRequired);
                return
            end

            names = reshape(string(names), 1, [ ]);
            if numel(names)~=size(this, dimension)
                exception.error([
                    "NamedMatrix:InvalidNumNames"
                    "Invalid number of %sNames assigned."
                ], dimensionName);
            end
            [flag, nonunique] = textual.nonunique(names);
            if flag
                exception.error([
                    "NamedMatrix:NonuniqueNames"
                    "Row and column names in NamedMatrix objects must be unique. "
                    "This name is being assigned more than once: %s"
                ], nonunique);
            end
        end%


        function this = set.RowNames(this, rowNames)
            this.RowNames = setNames(this, 1, rowNames);
        end%


        function this = set.ColNames(this, columnNames)
            this.ColNames = setNames(this, 2, columnNames);
        end%


        function value = get.ColumnNames(this)
            value = this.ColNames;
        end%


        function this = set.ColumnNames(this, value)
            this.ColNames = value;
        end%
    end


    methods
        function this = abs(this)
            rowNames = this.RowNames;
            columnNames = this.ColNames;
            this = abs@double(this);
            this = namedmat(this, rowNames, columnNames);
        end%

        function this = round(this, varargin)
            rowNames = this.RowNames;
            columnNames = this.ColNames;
            this = round@double(this, varargin{:});
            this = namedmat(this, rowNames, columnNames);
        end%
    end


    methods (Hidden)
        varargout = disp(varargin)
    end


    methods (Static, Hidden)
        varargout = myselect(varargin)
    end
end

