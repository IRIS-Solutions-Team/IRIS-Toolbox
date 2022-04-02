classdef (Abstract) Kalman

    properties (Constant, Hidden)
        DIFFUSE_SCALE = 1e8
        VARIANCE_FACTOR_TOLERANCE = eps()^(7/9)
        MEASUREMENT_MATRIX_TOLERANCE = eps()^(5/9)
        OBJ_FUNC_PENALTY = 1e+10
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
    end


    methods (Abstract, Hidden)
        varargout = hasLogVariables(varargin)
        varargout = countVariants(varargin)
    end


    methods (Static)
        varargout = initialize(varargin)
        varargout = combineStdcorr(varargin)
        varargout = predictErrorDecomposition(varargin)
        varargout = smootherForVAR(varargin)
    end
end
