classdef Incidence
    properties
        Shift
        Matrix
    end


    properties (Dependent)
        PosOfZeroShift
        NumOfShifts
        NumOfQuantities
        NumOfEquations
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
        varargout = testCompatible(varargin)


        function this = removeTrailingShifts(this)
            inc = across(this, 'Equations');
            anyInc = any(inc, 1);
            firstInc = find(anyInc, 1);
            lastInc = find(anyInc, 1, 'last');
            numQuantities = this.NumOfQuantities;
            if lastInc<this.NumOfShifts
                this.Shift = this.Shift(1:lastInc);
                this.Matrix = this.Matrix(:, 1:lastInc*numQuantities);
            end
            if firstInc>1
                this.Shift = this.Shift(firstInc:end);
                this.Matrix = this.Matrix(:, (firstInc-1)*numQuantities+1:end);
            end
        end%
            
        varargout = selectShift(varargin)
        

        function this = selectEquation(this, selector)
            this.Matrix = this.Matrix(selector, :);
        end%


        varargout = size(varargin)
    end


    methods
        function pos = get.PosOfZeroShift(this)
            pos = find(this.Shift==0);
        end%


        function nsh = get.NumOfShifts(this)
            nsh = length(this.Shift);
        end%


        function n = get.NumOfQuantities(this)
            n = size(this.Matrix, 2) / this.NumOfShifts;
        end%


        function n = get.NumOfEquations(this)
            n = size(this.Matrix, 1);
        end%


        function minShift = get.MinShift(this)
            sh0 = this.PosOfZeroShift;
            inc = across(this, 'Eqtn');
            inc = any(inc, 1);
            minShift = find(inc, 1) - sh0;
        end%


        function maxShift = get.MaxShift(this)
            sh0 = this.PosOfZeroShift;
            inc = across(this, 'Eqtn');
            inc = any(inc, 1);
            maxShift = find(inc, 1, 'Last') - sh0;
        end%


        function fullMatrix = get.FullMatrix(this)
            fullMatrix = full(this.Matrix);
            numShifts = this.NumOfShifts;
            numQuantities = size(fullMatrix, 2) / numShifts;
            fullMatrix = reshape(fullMatrix, [ ], numQuantities, numShifts);
        end%
    end
    
    
    methods (Static)
        varargout = getIncidenceEps(varargin)        
    end
end
