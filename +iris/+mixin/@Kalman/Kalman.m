classdef (Abstract) Kalman

    properties (Constant, Hidden)
        DIFFUSE_SCALE = 1e8
        VARIANCE_FACTOR_TOLERANCE = eps()^(7/9)
        MEASUREMENT_MATRIX_TOLERANCE = eps()^(5/9)
        OBJ_FUNC_PENALTY = 1e+10
        MEAN_OUTPUT = "Mean"
        MEDIAN_OUTPUT = "Median"
        CONTRIBS_OUTPUT = "Contribs"
        STD_OUTPUT = "Std"
        MSE_OUTPUT = "MSE"
    end


    methods (Abstract, Hidden)
        varargout = evalTrendEquations(varargin)
        varargout = sizeSolution(varargin)
        varargout = getIthKalmanSystem(varargin)
        varargout = getIthStdcorr(varargin)
        varargout = getIthOmega(varargin)
    end


    methods (Hidden)
        varargout = implementKalmanFilter(varargin)
        varargout = prepareKalmanOptions(varargin)
        varargout = prepareKalmanOptions2(varargin)
        varargout = prepareKalmanData(varargin)
    end


    methods (Abstract, Hidden)
        varargout = hasLogVariables(varargin)
        varargout = countVariants(varargin)
        varargout = getKalmanDataNames(varargin)
    end


    methods (Static)
        varargout = combineStdcorr(varargin)
        varargout = contributions(varargin)
        varargout = correct(varargin)
        varargout = initialize(varargin)
        varargout = likelihood(varargin)
        varargout = oneStepBackMean(varargin)
        varargout = PbFromPa(varargin)
        varargout = predictErrorDecomposition(varargin)
        varargout = smootherForVAR(varargin)
    end
end
