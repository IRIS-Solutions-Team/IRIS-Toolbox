classdef DataProcessor
    properties
        Preprocessor Explanatory = Explanatory.empty(0)
        Postprocessor Explanatory = Explanatory.empty(0)
    end


    methods
        function pre = accessPreprocessor(this)
            pre = this.Preprocessor;
        end%


        function post = accessPostprocessor(this)
            post = this.Postprocessor;
        end%


        function this = assignPreprocessor(this, pre)
            this.Preprocessor = pre;
        end%


        function this = assignPostprocessor(this, post)
            this.Postprocessor = post;
        end%


        function varargout = preprocess(this, varargin)
            [varargout{1:nargout}] = runProcessor(this, this.Preprocessor, varargin{:});
        end%


        function varargout = postprocess(this, varargin)
            [varargout{1:nargout}] = runProcessor(this, this.Postprocessor, varargin{:});
        end%


        function [outputDb, info] = runProcessor(this, processor, inputDb, baseRange, varargin)
            isSteady = (isstring(baseRange) || ischar(baseRange)) ...
                && any(strcmpi(baseRange, ["Steady", "SteadyLevel", "SteadyChange"]));
            if isSteady
                steadyInput = baseRange;
                [inputData, baseRange] = getInputDataForSteady(this, processor);
            else
                inputData = inputDb;
            end
            [outputData, info] = simulate(processor, inputData, baseRange, varargin{:});
            if isSteady
                outputDb = getOutputDataForSteady(this, processor, outputData, inputDb, steadyInput);
            else
                outputDb = outputData;
            end
        end%


        function [inputData, baseRange] = getInputDataForSteady(this, processor)
            [minSh, maxSh] = getActualMinMaxShifts(processor);
            baseRange = 0 : 1;
            extRange = baseRange(1) + minSh : baseRange(end) + maxSh;
            inputData = iris.mixin.DataBlock( );
            [inputData.YXEPG, ~, inputData.Names] = createTrendArray(this, @all, true, @all, extRange);
            inputData.ExtendedRange = extRange;
            inputData.BaseRangeColumns = [false(1, abs(minSh)), true(1, 2), false(1, maxSh)];
        end%


        function runningDb = getOutputDataForSteady(this, processor, outputDataBlock, runningDb, steadyInput)
            if ~validate.databank(runningDb)
                runningDb = struct( );
            end
            baseRangeColumns = outputDataBlock.BaseRangeColumns;
            lhsNames = collectLhsNames(processor);
            logStatus = collectLogStatus(processor);
            if strcmpi(steadyInput, "Steady")
                funcLogFalse = @(x) complex(x(1, 1, :), x(1, 2, :)-x(1, 1, :));
                funcLogTrue = @(x) complex(x(1, 1, :), x(1, 2, :)./x(1, 1, :));
            elseif strcmpi(steadyInput, "SteadyLevel")
                funcLogFalse = @(x) x(1, 1, :);
                funcLogTrue = funcLogFalse;
            elseif strcmpi(steadyInput, "SteadyChange")
                funcLogFalse = @(x) x(1, 2, :)-x(1, 1, :);
                funcLogTrue = @(x) x(1, 2, :)./x(1, 1, :);
            end

            for i = 1 : numel(lhsNames)
                pos = outputDataBlock.Names==lhsNames(i);
                x = outputDataBlock.YXEPG(pos, baseRangeColumns, :);
                if logStatus(i)
                    x = funcLogTrue(x);
                else
                    x = funcLogFalse(x);
                    if imag(x)==0
                        x = real(x);
                    end
                end
                runningDb.(lhsNames(i)) = reshape(x, 1, [ ]);
            end
        end%
    end
end

