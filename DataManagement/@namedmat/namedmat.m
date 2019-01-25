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
% -Copyright (c) 2007-2019 IRIS Solutions Team.

classdef namedmat < double % >>>>> MOSW classdef namedmat
    
    properties (SetAccess = protected)
        RowNames = cell.empty(1, 0);
        ColNames = cell.empty(1, 0);
    end
    

    methods
        function this = namedmat(X, varargin)
            % namedmat  Create a new matrix with named rows and columns.
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
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2019 IRIS Solutions Team.
            
            %--------------------------------------------------------------
            
            if nargin==0
                X = double.empty(0, 0);
            end
            this = this@double(X);
            if ~isempty(varargin)
                this.RowNames = varargin{1};
                varargin(1) = [ ];
            end
            if ~isempty(varargin)
                this.ColNames = varargin{1};
                varargin(1) = [ ]; %#ok<NASGU>
            elseif ~isempty(this.RowNames)
                this.ColNames = this.RowNames;
            end
        end
        
        
        function disp(this)
            disp(double(this));
            addspace = false;
            if ~isempty(this.RowNames)
                disp(['   Rows:', sprintf(' %s', this.RowNames{:})]);
                addspace = true;
            end
            if ~isempty(this.ColNames)
                disp(['Columns:', sprintf(' %s', this.ColNames{:})]);
                addspace = true;
            end
            if addspace
                textfun.loosespace( );
            end
        end

        
        varargout = colnames(varargin)
        varargout = ctranspose(varargin)
        varargout = cutoff(varargin);
        varargout = horzcat(varargin)
        varargout = plot(varargin)
        varargout = rownames(varargin)
        varargout = select(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)
        varargout = transpose(varargin)
        varargout = vertcat(varargin)    


        function this = set.RowNames(this, rowNames)
            if isempty(rowNames)
                return
            end
            numOfRows = size(this, 1);
            assert( ...
                iscellstr(rowNames) && numel(rowNames)==numOfRows, ...
                'namedmat:namedmat', ...
                'Row names must be entered as a cellstr matching the number of rows.' ...
            );
            this.RowNames = rowNames;
        end


        function this = set.ColNames(this, columnNames)
            if isempty(columnNames)
                return
            end
            numOfColumns = size(this, 2);
            assert( ...
                iscellstr(columnNames) && numel(columnNames)==numOfColumns, ...
                'namedmat:namedmat', ...
                'Column names must be entered as a cellstr matching the number of columns.' ...
            );
            this.ColNames = columnNames;
        end
    end
    
    
    methods
        function this = abs(this)
            rowNames = this.RowNames;
            columnNames = this.ColNames;
            this = abs@double(this);
            this = namedmat(this, rowNames, columnNames);
        end
    end

            
    methods (Static, Hidden)
        varargout = myselect(varargin)


        function flag = validateMatrixFormat(format)
            flag = any(strcmpi(format, {'Plain', 'Numeric', 'NamedMat'}));
        end
    end
end
