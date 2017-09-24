classdef Incidence
    properties
        Shift
        Matrix
    end


    properties (Dependent)
        PosOfZeroShift
        NumOfShifts
        MinShift
        MaxShift
        FullMatrix
    end
    
    
    methods
        function this = Incidence(nEqtn, nQuan, minSh, maxSh)
            if nargin==0
                return
            end
            this.Shift = (minSh-1) : (maxSh+1);
            nsh = length(this.Shift);
            this.Matrix = logical( sparse(nEqtn, nQuan*nsh) );
        end
    end
    
    
    methods
        varargout = across(varargin)
        varargout = fill(varargin)
        varargout = find(varargin)
        varargout = implementGet(varargin)
        varargout = isCompatible(varargin)
        varargout = selectShift(varargin)
        varargout = selectEquation(varargin)
        varargout = size(varargin)
    end


    methods
        function pos = get.PosOfZeroShift(this)
            pos = find(this.Shift==0);
        end


        function nsh = get.NumOfShifts(this)
            nsh = length(this.Shift);
        end


        function minShift = get.MinShift(this)
            sh0 = this.PosOfZeroShift;
            inc = across(this, 'Eqtn');
            inc = any(inc, 1);
            minShift = find(inc, 1) - sh0;
        end


        function maxShift = get.MaxShift(this)
            sh0 = this.PosOfZeroShift;
            inc = across(this, 'Eqtn');
            inc = any(inc, 1);
            maxShift = find(inc, 1, 'Last') - sh0;
        end


        function fullMatrix = get.FullMatrix(this)
            fullMatrix = full(this.Matrix);
            numOfShifts = this.NumOfShifts;
            numOfQuantities = size(fullMatrix, 2) / numOfShifts;
            fullMatrix = reshape(fullMatrix, [ ], numOfQuantities, numOfShifts);
        end
    end
    
    
    methods (Static)
        varargout = getIncidenceEps(varargin)        
    end
end
