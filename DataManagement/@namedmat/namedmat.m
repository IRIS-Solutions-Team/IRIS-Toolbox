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
% -Copyright (c) 2007-2020 IRIS Solutions Team.

classdef namedmat < double % >>>>> MOSW classdef namedmat
    properties (SetAccess = protected)
        RowNames = cell.empty(1, 0);
        ColNames = cell.empty(1, 0);
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
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------
            
            if nargin==0
                X = double.empty(0, 0);
            end
            this = this@double(X);
            this.RowNames = repmat({''}, 1, size(X, 1));
            this.ColNames = repmat({''}, 1, size(X, 2));
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


        function this = set.RowNames(this, rowNames)
            if isempty(rowNames)
                return
            end
            numOfRows = size(this, 1);
            if ~iscellstr(rowNames) || numel(rowNames)~=numOfRows
                THIS_ERROR = { 'NamedMatrix:InvalidRowNames'
                               'Row names must be entered as a cellstr matching the number of rows.' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end
            this.RowNames = rowNames;
        end%


        function this = set.ColNames(this, columnNames)
            if isempty(columnNames)
                return
            end
            numOfColumns = size(this, 2);
            if ~iscellstr(columnNames) || numel(columnNames)~=numOfColumns
                THIS_ERROR = { 'NamedMatrix:InvalidColumnNames'
                               'Column names must be entered as a cellstr matching the number of columns.' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end
            this.ColNames = columnNames;
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
    end


    methods (Hidden)
        varargout = disp(varargin)
    end

            
    methods (Static, Hidden)
        varargout = myselect(varargin)

        % TODO: Move to @Valid
        function flag = validateMatrixFormat(format)
            flag = any(strcmpi(format, {'Plain', 'Numeric', 'NamedMatrix', 'NamedMat'}));
        end%
    end
end
