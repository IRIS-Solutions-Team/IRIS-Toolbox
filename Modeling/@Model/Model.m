classdef Model < model
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
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

            this = this@model(varargin{:});
        end%
    end


    methods
        varargout = simulate(varargin)
    end


    methods (Hidden) 
        varargout = checkCompatibilityOfPlan(varargin)
        varargout = checkInitialConditions(varargin)
        varargout = getIdOfInitialConditions(varargin)
        varargout = getInxOfInitInPresample(varargin)
        varargout = prepareHashEquations(varargin)
        varargout = simulateFirstOrder(varargin)
    end
end
