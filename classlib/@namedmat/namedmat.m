classdef namedmat < double % >>>>> MOSW classdef namedmat
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
    % Constructor
    % ============
    %
    % * [`namedmat`](namedmat/namedmat) - Create a new matrix with named rows and columns.
    %
    % Manipulating named matrices
    % ============================
    %
    % * [`select`](namedmat/select) - Select submatrix by referring to row names and column names.
    % * [`transpose`](namedmat/transpose) - Transpose each page of matrix with names rows and columns.
    %
    % Getting row and column names
    % =============================
    %
    % * [`rownames`](namedmat/rownames) - Names of rows in namedmat object.
    % * [`colnames`](namedmat/colnames) - Names of columns in namedmat object.
    %
    % Sample characteristics
    % =======================
    %
    % * [`cutoff`](namedmat/cutoff] - 
    %
    % All operators and functions available for standard Matlab matrices
    % and arrays (i.e. double objects) are also available for namedmat
    % objects.
    %
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2017 IRIS Solutions Team.
    
    
    properties (SetAccess = protected)
        RowNames = { };
        ColNames = { };
    end
    
    
    methods
        function This = namedmat(X,varargin)
            % namedmat  Create a new matrix with named rows and columns.
            %
            % Syntax
            % =======
            %
            %     X = namedmat(X,RowNames,ColNames)
            %     X = namedmat(X,Names)
            %
            % Input arguments
            % ================
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
            % Output arguments
            % =================
            %
            % * `X` [ namedmat ] - Matrix with named rows and columns.
            %
            % Description
            % ============
            %
            % Namedmat objects are used by some of the IRIS functions to
            % preserve the names of variables that relate to individual
            % rows and columns, such as in
            %
            % * `acf`, the autocovariance and autocorrelation functions,
            % * `xsf`, the power spectrum and spectral density functions,
            % * `fmse`, the forecast mean square error fuctions,
            % * etc.
            %
            % You can use the function [`select`](namedmat/select) to
            % extract submatrices by referring to a selection of names.
            %
            % Namedmat matrices derives from the built-in double class of
            % objects, and hence you can use any operators and functions on
            % them that are available for double objects.
            %
            % Example
            % ========
            %
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2017 IRIS Solutions Team.
            
            %--------------------------------------------------------------
            
            if nargin == 0
                X = [ ];
            end
            This = This@double(X);
            if ~isempty(varargin)
                This.RowNames = varargin{1};
                varargin(1) = [ ];
                if ~isempty(This.RowNames) ...
                        && length(This.RowNames) ~= size(X,1)
                    utils.error('namedmat:namedmat', ...
                        'Number of row names must match number of rows.');
                end
                if ~isempty(varargin)
                    This.ColNames = varargin{1};
                    varargin(1) = [ ]; %#ok<NASGU>
                    if ~isempty(This.ColNames) ...
                            && length(This.ColNames) ~= size(X,2)
                        utils.error('namedmat:namedmat', ...
                            ['Number of column names must match ', ...
                            'number of columns.']);
                    end
                end
            end
        end
        
        
        function disp(this)
            disp(double(this));
            addspace = false;
            if ~isempty(this.RowNames)
                disp(['   Rows:',sprintf(' %s',this.RowNames{:})]);
                addspace = true;
            end
            if ~isempty(this.ColNames)
                disp(['Columns:',sprintf(' %s',this.ColNames{:})]);
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
    end
    
    
    methods (Static,Hidden)
        varargout = myselect(varargin)
    end
    
    
end
