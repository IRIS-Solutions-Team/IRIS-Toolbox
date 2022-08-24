classdef Link
    properties
        % Input  Cell array of input equations
        Input = cell.empty(1, 0) 

        % LhsPtr  Int8 array of pointers to LHS variables
        LhsPtr = int8.empty(1, 0)

        % RhsExpn  Cell array of link expressions
        RhsExpn = cell.empty(1, 0)

        % Order  Ordering of links
        Order = int16.empty(1, 0)
    end




    properties (Dependent)
        InxActive
        LhsPtrActive
        RhsExpnActive
    end




    methods
        varargout = reorder(varargin)
        varargout = refresh(varargin)


        function n = length(this)
            n = length(this.LhsPtr);
        end%


        function n = numel(this)
            n = numel(this.LhsPtr);
        end%


        function flag = isempty(this)
            flag = isempty(this.LhsPtr);
        end%


        function flag = any(this)
            flag = any(this.LhsPtr>0);
        end%


        function [this, inxValid] = changeActivationStatus(this, lhsPtr, newStatus)
            absLhsPtr = abs(this.LhsPtr);
            [posLink, inxValid] = lookup(this, lhsPtr);
            this.LhsPtr(posLink) = sign(newStatus)*absLhsPtr(posLink);
        end%


        function [posLink, inxValid, lhsPtr] = lookup(this, lhsPtr)
            if isequal(lhsPtr, @all)
                inxValid = true;
                posLink = 1 : numel(this.LhsPtr);
                lhsPtr = abs(this.LhsPtr);
            else
                [inxValid, posLink] = ismember(lhsPtr, abs(this.LhsPtr));
            end
        end%


        function inxActive = get.InxActive(this)
            PTR = @int16;
            inxActive = this.LhsPtr>PTR(0);
        end%


        function value = get.LhsPtrActive(this)
            value = this.LhsPtr(this.InxActive);
        end%
    end




    methods % Constructor
        %(
        function this = Link(equations, equationsUnderConstruction, quantities)
            if nargin==0
                return
            end

            PTR = @int16;

            inxL = equations.Type==4;
            if ~any(inxL)
                return
            end

            numEquations = numel(equations.Input);
            numQuantities = numel(quantities.Name);
            lhsNames = equationsUnderConstruction.LhsDynamic(inxL);
            ell = lookup(quantities, lhsNames);
            inxValidName = ~isnan(ell.PosName);
            inxValidStdCorr = ~isnan(ell.PosStdCorr);
            inxValid = inxValidName | inxValidStdCorr;
            if any(~inxValid)
                listInvalid = equations.Input(inxL);
                listInvalid = listInvalid(~inxValid);
                throw(exception.Base('Equation:INVALID_LHS_LINK', 'error'), listInvalid{:});
            end

            numLinks = nnz(inxL);
            ptr = repmat(PTR(0), 1, numLinks);
            ptr(inxValidName) = PTR(ell.PosName(inxValidName));
            ptr(inxValidStdCorr) = PTR(numQuantities + ell.PosStdCorr(inxValidStdCorr));
            this.Input = equations.Input(inxL);
            this.LhsPtr = ptr;
            this.Order = PTR(1:numLinks);
            this.RhsExpn = regexprep(equations.Dynamic(inxL), '^-\[[^\]]*\]\+', '');
        end%
        %)
    end
end

