classdef Gradient 
    properties
        % Dynamic  Cell array, 3-by-N, describing the derivatives of
        % dynamic equations {gradient function; wrt; ids withing gradient}
        Dynamic (3, :) cell = cell.empty(3, 0)


        % Steady  Cell array, 3-by-N, describing the derivatives of steady
        % equations {gradient function; wrt; ids withing gradient}
        Steady (3, :) cell = cell.empty(3, 0)
    end


    methods
        function this = Gradient(n)
            if nargin==0
                return
            end
            this.Dynamic = cell(3, n);
            this.Steady = cell(3, n);
        end%

        varargout = implementGet(varargin)
        varargout = size(varargin)
    end


    methods (Static)
        varargout = array2symb(varargin)
        varargout = diff(varargin)
        varargout = symb2array(varargin)
        varargout = lookupIdsWithinGradient(varargin)
        varargout = repmatGradient(varargin)
    end
end

