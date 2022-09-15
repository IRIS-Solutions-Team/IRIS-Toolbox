% ChiSquare  ChiSquare distribution object
%
%
% ChiSquare methods:
%
% __Constructors__
%
% The following are static constructors and need to be called with
% `distribution.ChiSquare.` preceding their names.
%
%   fromDegreesFreedom - 
%
%
% __Distribution Properties__
%
% These properties are directly accessible through the distribution object,
% followed by a dot and the name of a property.
%
%   Name - Name of the distribution
%   Domain - Domain of the distribution
%
%   DegreesFreedom - 
%   Alpha - 
%   Beta - 
%   Mean - Mean (expected value) of distribution
%   Var - Variance of distribution
%   Std - Standard deviation of distribution
%   Mode - Mode of distribution
%   Median - Median of distribution
%   Location - Location parameter of distribution
%   Shape - Shape parameter of distribution
%   Scale - Scale parameter of distribution
%
%
% __Density Related Functions__
%
%   pdf - Probability density function
%   logPdf - Log of probability density function up to constant
%   info - Minus second derivative of log of probability density function
%   inDomain - True for data points within domain of distribution function
%
%
% __Description__
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

classdef ChiSquare ...
    < distribution.Distribution ...
    & distribution.GammaFamily

    properties (SetAccess=protected)
        % DegreesFreedom  Number of the degrees of freedem of the distribution
        DegreesFreedom

        % Alpha  Alpha (shape) parameter of the underlying Gamma distribution
        Alpha = NaN
    end


    properties (Constant)
        % Beta  Beta (scale) parameter of the underlying Gamma distribution
        Beta = 2
    end


    methods
        function this = ChiSquare( )
            this.Name = 'ChiSquare';
            this.Domain = [0, Inf];
            this.Location = 0;
        end%


        function this = set.DegreesFreedom(this, value)
            if validate.numericScalar(value, 0, Inf)
                this.DegreesFreedom = value;
                return
            end
            thisError = [
                "ChiSquare:InvalidInput"
                "The value of the input parameter DegreesFreedom "
                "must be a positive integer scalar."
            ];
            throw(exception.Base(thisError, 'error'));
        end%
    end


    methods (Static)
        function this = fromDegreesFreedom(varargin)
            this = distribution.ChiSquare( );
            this.DegreesFreedom = varargin{1};
            this.Alpha = this.DegreesFreedom / 2;
            populateParameters(this);
        end%
    end
end
