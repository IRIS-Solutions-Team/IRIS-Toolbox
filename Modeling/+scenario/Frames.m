classdef Frames < handle
    properties
        IndexOfEndogenized(:, :, :) logical = logical.empty(1, 0, 0)
        IndexOfExogenized(:, :, :) logical = logical.empty(1, 0, 0)
        ValuesOfExogenized(:, :, :) double = double.empty(1, 0, 0)
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
            this.IndexOfEndogenized = false(numNames, numPeriods, numPeriods);
            this.IndexOfExogenized = false(numNames, numPeriods, numPeriods);
            this.ValuesOfExogenized = nan(numNames, numPeriods, numPeriods);
        end%


        function flag = compareFrames(this, i, j)
            compareFrom = max(i, j);
            flag = isequal(this.IndexOfEndogenized(:, compareFrom:end, i), this.IndexOfEndogenized(:, compareFrom:end, j)) ...
                && isequal(this.IndexOfExogenized(:, compareFrom:end, i), this.IndexOfExogenized(:, compareFrom:end, j)) ...
                && isequaln(this.ValuesOfExogenized(:, compareFrom:end, i), this.ValuesOfExogenized(:, compareFrom:end, j));
        end%


        function exogenize(this, posOfNames, posOfStartDate, posOfEndDate, posOfStartFrame, posOfEndFrame)
            if isempty(posOfStartFrame) && isempty(posOfEndFrame)
                % Unanticipated
                for i = posOfStartDate : posOfEndDate
                    this.IndexOfExogenized(posOfNames, i, i) = true;
                end
            else
                % Anticipated
                this.IndexOfExogenized( posOfNames, ...
                                        posOfStartDate:posOfEndDate, ...
                                        posOfStartFrame:posOfEndFrame ) = true;
            end
        end%


        function endogenize(this, posOfNames, posOfStartDate, posOfEndDate, posOfStartFrame, posOfEndFrame)
            if isempty(posOfStartFrame)
                % Unanticipated
                for i = posOfStartDate : posOfEndDate
                    this.IndexOfEndogenized(posOfNames, i, i) = true;
                end
            else
                % Anticipated
                this.IndexOfEndogenized( posOfNames, ...
                                         posOfStartDate:posOfEndDate, ...
                                         posOfStartFrame:posOfEndFrame ) = true;
            end
        end%
    end


    methods
        function n = get.NumOfNames(this)
            n = size(this.IndexOfExogenized, 1);
        end%
            

        function n = get.NumOfPeriods(this)
            n = size(this.IndexOfExogenized, 2);
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
                n(i) = nnz(this.IndexOfExogenized(:, :, segments{i}));
            end
        end%


        function n = get.NumOfEndogenized(this)
            segments = this.Segments;
            n = nan(size(segments));
            for i = 1 : numel(segments)
                n(i) = nnz(this.IndexOfEndogenized(:, :, segments{i}));
            end
        end%


        function determinacy = get.Determinacy(this)
            determinacy = this.NumOfExogenized - this.NumOfEndogenized;
        end%
    end
end
