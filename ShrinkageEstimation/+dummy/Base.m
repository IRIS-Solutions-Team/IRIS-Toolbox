% Base  Base class for prior dummy observations
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

classdef (Abstract) Base
    methods (Abstract)
        varargout = evalY(varargin)
        varargout = evalZ(varargin)
        varargout = evalK(varargin)
        varargout = evalX(varargin)
    end


    methods
        function dummy = eval(this, var)
            dummy = struct();
            dummy.Y = this.evalY(var);
            dummy.Z = this.evalZ(var);
            dummy.K = this.evalK(var);
            dummy.X = this.evalX(var);
            dummy.NumDummyColumns = size(dummy.Y, 2);
        end%
    end


    methods (Static)
        function [numY, numK, numX, order] = getDimensions(var)
            numY = numel(var.EndogenousNames);
            numK = nnz(var.Intercept);
            numX = numel(var.ExogenousNames);
            order = var.Order;
        end%


        function dummy = evalCollection(collection, var)
            if ~iscell(collection)
                collection = {collection};
            end
            dummy = struct('Y', [], 'Z', [], 'K', [], 'X', []);
            for x = reshape(collection, 1, [])
                add = eval(x{:}, var);
                for f = textual.fields(dummy)
                    dummy.(f) = [dummy.(f), add.(f)];
                end
            end
            dummy.NumDummyColumns = size(dummy.Y, 2);
        end%
    end
end

