classdef Frames < handle
    properties
        % AnchorsEndogenized  Location of endogenized data points
        AnchorsEndogenized(:, :, :) logical = logical.empty(0, 0, 0)

        % AnchorsExogenized  Location of exogenized data points
        AnchorsExogenized(:, :, :) logical = logical.empty(0, 0, 0)

        % ValuesExogenized  Values of exogenized data points
        ValuesExogenized(:, :, :) double = double.empty(0, 0, 0)

        % AnchorsExogenous  Location of non-zero exogenous data points
        AnchorsExogenous(:, :, :) logical = logical.empty(0, 0, 0)

        % ValuesExogenous  Values of exogenous data points
        ValuesExogenous(:, :, :) double = double.empty(0, 0, 0)
    end

    
    properties (Dependent)
        NumOfNames
        NumOfPeriods
        Segments
        NumOfSegments
        NumOfExogenized
        NumOfEndogenized
        Determinacy
    end


    methods
        function this = Frames(numNames, numPeriods)
            if nargin==0
                return
            end
            this.AnchorsEndogenized = false(numNames, numPeriods, numPeriods);
            this.AnchorsExogenized = false(numNames, numPeriods, numPeriods);
            this.ValuesExogenized = nan(numNames, numPeriods, numPeriods);
            this.AnchorsExogenous = false(numNames, numPeriods, numPeriods);
            this.ValuesExogenous = nan(numNames, numPeriods, numPeriods);
        end%


        function flag = compareFrames(this, i, j)
            compareFrom = max(i, j);
            flag = isequal(this.AnchorsEndogenized(:, compareFrom:end, i), this.AnchorsEndogenized(:, compareFrom:end, j)) ...
                && isequal(this.AnchorsExogenized(:, compareFrom:end, i), this.AnchorsExogenized(:, compareFrom:end, j)) ...
                && isequaln(this.ValuesExogenized(:, compareFrom:end, i), this.ValuesExogenized(:, compareFrom:end, j)) ...
                && isequal(this.AnchorsExogenous(:, compareFrom:end, i), this.AnchorsExogenous(:, compareFrom:end, j)) ...
                && isequaln(this.ValuesExogenous(:, compareFrom:end, i), this.ValuesExogenous(:, compareFrom:end, j)) ;
        end%


        function endogenize(this, varargin)
            setAnchors(this, 'AnchorsEndogenized', varargin{:});
        end%


        function endogenize(this, varargin)
            setAnchors(this, 'AnchorsExogenized', varargin{:});
        end%


        function exogenous(this, varargin)
            setAnchors(this, 'AnchorsExogenous', varargin{:});
        end%


        function setAnchors( this, anchor, posOfNames, ...
                             posOfStartDate, posOfEndDate, ...
                             posOfStartFrame, posOfEndFrame )
            if isempty(posOfStartFrame)
                % Unanticipated
                for i = posOfStartDate : posOfEndDate
                    this.(anchor)(posOfNames, i, i) = true;
                end
            else
                % Anticipated
                this.(anchor)( posOfNames, ...
                               posOfStartDate:posOfEndDate, ...
                               posOfStartFrame:posOfEndFrame ) = true;
            end
        end% 


        function clearValues(this)
            clearValuesExogenized(this);
            clearValuesExogenous(this);
        end%


        function clearValuesExogenized(this)
            this.ValuesExogenized(:) = NaN;
        end%


        function clearValuesExogenous(this)
            this.ValuesExogenous(:) = NaN;
        end%
    end


    methods
        function n = get.NumOfNames(this)
            n = size(this.AnchorsExogenized, 1);
        end%
            

        function n = get.NumOfPeriods(this)
            n = size(this.AnchorsExogenized, 2);
        end%


        function n = get.NumOfSegments(this)
            n = numel(this.Segments);
        end%


        function segments = get.Segments(this)
            segments = cell.empty(1, 0);
            numPeriods = this.NumOfPeriods;
            if numPeriods==0
                return
            end
            currentSegment = 1;
            for i = 2 : numPeriods
                if compareFrames(this, i-1, i)
                    currentSegment = [currentSegment, i];
                else
                    segments{end+1} = currentSegment;
                    currentSegment = i;
                end
            end
            if ~isempty(currentSegment)
                segments{end+1} = currentSegment;
            end
        end%


        function n = get.NumOfExogenized(this)
            segments = this.Segments;
            n = nan(size(segments));
            for i = 1 : numel(segments)
                n(i) = nnz(this.AnchorsExogenized(:, :, segments{i}));
            end
        end%


        function n = get.NumOfEndogenized(this)
            segments = this.Segments;
            n = nan(size(segments));
            for i = 1 : numel(segments)
                n(i) = nnz(this.AnchorsEndogenized(:, :, segments{i}));
            end
        end%


        function determinacy = get.Determinacy(this)
            determinacy = this.NumOfExogenized - this.NumOfEndogenized;
        end%
    end
end
