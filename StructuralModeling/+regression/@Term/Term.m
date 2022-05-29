classdef Term
    properties
        InputString = ""
        Incidence (1, :) double = double.empty(1, 0)
        Position (1, 1) double = NaN
        Shift (1, 1) double = 0

        Expression = [ ]
        BuildSimulate = [ ]
        InverseTransform = [ ]

        ContainsLhsName (1, 1) logical = false
        ContainsCurrentLhsName (1, 1) logical = false
        ContainsLaggedLhsName (1, 1) logical = false

        MinShift (1, 1) double = 0
        MaxShift (1, 1) double = 0
    end


    methods % Constructor
        function this = Term(expy, specification, type, varargin)
% Term  Create RHS term for Explanatory object
%{
% ## Syntax ##
%
%
%     term = regression.Term(expy, expression)
%     term = regression.Term(expy, position, ...)
%
%
% ## Input Arguments ##
%
%
% __`expy`__ [ Explanatory ]
% >
% Parent Explanatory object to which the regression.Term will be
% added.
%
%
% __`expression`__ [ string ]
% > 
% Create the regression.Term from a text string describing a possibly
% nonlinear function involving variable names defined in the parent
% Explanatory object.
%
%
% __`position`__ [ numeric ]
% >
% Create the regression.Term from a single variable a simple `Transform=`
% function by specifying a pointer to the list of variables names in the
% parent Explanatory object.
% 
%
% ## Output Arguments ##
%
% __`term`__ [ regression.Term ]
% >
% New regression.Term object that can be added to its parent
% Explanatory object.
%
%
% ## Options ##
%
%
% The following options can be used if the regression.Term is being created
% from a `position`, not from an `expression`.
%
%
% __`Shift=0`__ [ numeric ]
% >
% Time shift (lag or lead) of the explanatory variable.
%
%
% __`Transform=''`__ [ empty | `'diff'` | `'log'` | `'difflog'` ]
% >
% Tranformation of the explanatory variable.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

            if nargin==0
                return
            end

            %
            % Resolve input specification
            %
            this = regression.Term.parseInputSpecs(this, expy, specification, type);

            imagIncidence0 = [imag(this.Incidence), 0];
            this.MinShift = min(imagIncidence0);
            this.MaxShift = max(imagIncidence0);
        end%
    end


    methods
        function y = createModelData(this, plainData, t, controls)
            if islogical(t)
                t = find(t);
            end
            numTerms = numel(this);
            numPages = size(plainData, 3);
            numBasePeriods = numel(t);
            y = nan(numTerms, numBasePeriods, numPages);
            for i = 1 : numTerms
                this__ = this(i);
                y__ = this__.Expression(plainData, [ ], [ ], t, ':', controls);
                %
                % The function may not point to any variables and
                % produce simply a scalar constant instead; extend the
                % values throughout the range and pages
                %
                if size(y__, 2)==1 && numBasePeriods>1
                    y__ = repmat(y__, 1, numBasePeriods, 1);
                end
                if size(y__, 3)==1 && numPages>1
                    y__ = repmat(y__, 1, 1, numPages);
                end
                y(i, :, :) = y__;
            end
        end%




        function flag = isequaln(obj1, obj2)
            if ~isequal(class(obj1), class(obj2))
                flag = false;
                return
            end
            if ~isequal(size(obj1), size(obj2))
                flag = false;
                return
            end
            if isempty(obj1) && isempty(obj2)
                flag = true;
                return
            end
            meta = ?regression.Term;
            list = setdiff({meta.PropertyList.Name}, 'Expression');
            for i = 1 : numel(obj1)
                if ~isequal(char(obj1(i).Expression), char(obj2(i).Expression))
                    flag = false;
                    return
                end
                for p = reshape(string(list), 1, [ ])
                    if ~isequaln(obj1(i).(p), obj2(i).(p))
                        flag = false;
                        return
                    end
                end
            end
            flag = true;
        end%
    end




    methods
        function this = containsLhsName(this, posLhs)
            this.ContainsLhsName = any(real(this.Incidence)==posLhs);
            this.ContainsCurrentLhsName = any(real(this.Incidence)==posLhs & imag(this.Incidence)==0);
            this.ContainsLaggedLhsName = any(real(this.Incidence)==posLhs & imag(this.Incidence)<0);
        end%




        function output = eq(this, that)
            numThis = numel(this);
            numThat = numel(that);
            if numThis==1 && numThat>1
                this = repmat(this, size(that));
            elseif numThis>1 && numThat==1
                that = repmat(that, size(this));
            end
            output = arrayfun(@isequal, this, that);
        end%
    end




    methods (Static)
        varargout = parseInputSpecs(varargin)
    end
end

