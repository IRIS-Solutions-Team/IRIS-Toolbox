classdef Model < model & matlab.mixin.CustomDisplay
    methods % Constructor
        function this = Model(varargin)
% Model  Create Model object from a source model file
%
% __Syntax__ 
%
%     m = Model(fileNames, ...)
%
%
% __Input Arguments__
%
% * `fileNames` [ char | cellstr | string ] - File name or file names of
% source model files on which the model object will be base; if multiple
% source model files are entered, they will be combined.
%
% 
% __Output Arguments__
%
% * `m` [ Model ] - New model object based on the source model file(s)
% specified in `fileNames`.
%
%
% __Options__
%
%
% __Description__
%
%
% __Example__
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

            this = this@model(varargin{:});
        end%
    end


    methods
        varargout = simulate(varargin)
    end


    methods (Access=protected) % Custom Display
        function groups = getPropertyGroups(this)
            x = struct( 'FileName', this.FileName, ...
                        'Comment', this.Comment, ...
                        'IsLinear', this.IsLinear, ...
                        'NumOfVariants', this.NumOfVariants, ...
                        'NumOfVariantsSolved', this.NumOfVariantsSolved, ...
                        'NumOfMeasurementEquations', this.NumOfMeasurementEquations, ...
                        'NumOfTransitionEquations', this.NumOfTransitionEquations, ... 
                        'SizeOfTransitionMatrix', this.SizeOfTransitionMatrix, ...
                        'NumOfExportFiles', this.NumOfExportFiles, ...
                        'UserData', this.UserData );
            groups = matlab.mixin.util.PropertyGroup(x);
        end% 


        function displayScalarObject(this)
            groups = getPropertyGroups(this);
            disp(getHeader(this));
            disp(groups.PropertyList);
        end%


        function displayNonScalarObject(this)
            displayScalarObject(this);
        end%


        function header = getHeader(this)
            dimString = matlab.mixin.CustomDisplay.convertDimensionsToString(this);
            className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
            adjective = ' ';
            if isempty(this)
                adjective = [adjective, 'Empty '];
            end
            if this.IsLinear
                adjective = [adjective, 'Linear'];
            else
                adjective = [adjective, 'Nonlinear'];
            end
            header = ['  ', dimString, adjective, ' ', className, sprintf('\n')]; 
        end%
    end


    methods (Hidden) 
        varargout = checkCompatibilityOfPlan(varargin)
        varargout = checkInitialConditions(varargin)
        varargout = getIdOfInitialConditions(varargin)
        varargout = getInxOfInitInPresample(varargin)
        varargout = prepareHashEquations(varargin)
        varargout = simulateFirstOrder(varargin)
    end


    properties (Dependent)
        NumOfVariantsSolved
        NumOfMeasurementEquations
        NumOfTransitionEquations
        SizeOfTransitionMatrix
        NumOfExportFiles
    end


    methods
        function value = get.NumOfVariantsSolved(this)
            [~, inx] = isnan(this, 'Solution');
            value = nnz(~inx);
        end%


        function value = get.NumOfMeasurementEquations(this)
            TYPE = @int8;
            value = nnz(this.Equation.Type==TYPE(1));
        end%


        function value = get.NumOfTransitionEquations(this)
            TYPE = @int8;
            value = nnz(this.Equation.Type==TYPE(2));
        end%


        function value = get.SizeOfTransitionMatrix(this)
            [~, nxi, nb] = sizeOfSolution(this);
            value = [nxi, nb];
        end%


        function value = get.NumOfExportFiles(this)
            value = numel(this.Export);
        end%
    end
end
