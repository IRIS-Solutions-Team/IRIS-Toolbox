function defineFrames(this, opt)

% Accelerate when NumPages is large
methodFirstOrder = double(solver.Method.FIRSTORDER);
methodSelective = double(solver.Method.SELECTIVE);
methodPeriod = double(solver.Method.PERIOD);
method = double(this.Method);


dataBlock = iris.mixin.DataBlock();
numPages = this.NumPages;
this.FrameColumns = cell(1, numPages);
this.FrameDates = cell(1, numPages);
this.FrameData = cell(1, numPages);
this.MixinUnanticipated = false(1, numPages);
extRange = this.ExtendedRange;
startExtRange = extRange(1);

for page = 1 : this.NumPages
    here_defineFrames(this, page);

    numFrames = size(this.FrameColumns{page}, 1);
    if numFrames>opt.MaxFrames
        this.FrameColumns{page}(opt.MaxFrames+1:end, :) = [ ];
        numFrames = opt.MaxFrames;
    end
    frameDates = nan(numFrames, 2);
    deficiency{page} = zeros(1, numFrames);
    for frame = 1 : numFrames
        startFrame = startExtRange + this.FrameColumns{page}(frame, 1) - 1;
        endFrame = startExtRange + this.FrameColumns{page}(frame, end) - 1;
        frameDates(frame, :) = [startFrame, endFrame];
    end
    this.FrameDates{page} = frameDates;
end

if this.PrepareFrameData
    for page = 1 : this.NumPages
        this.FrameData{page} = copy(dataBlock);
    end
end

checkDeficiency(this);

return

    function here_defineFrames(this, page)
        %
        % For the PERIOD method, the frames are individual simulation periods
        %
        if method(page)==methodPeriod
            startFrame = reshape(this.BaseRangeColumns, [ ], 1);
            endFrame = reshape(this.BaseRangeColumns, [ ], 1);
            this.FrameColumns{page} = [startFrame, endFrame];
            return
        end

        firstColumnSimulation = this.BaseRangeColumns(1);
        lastColumnSimulation = this.BaseRangeColumns(end);
        numRows = size(this.YXEPG, 1);
        numColumns = size(this.YXEPG, 2);

        %
        % Retrieve unanticipated shocks from the input data
        %
        inxAnticipatedE = logical(sparse(1, numRows));
        inxUnanticipatedE = logical(sparse(1, numRows));
        inxAnticipatedE(this.InxE) = this.Plan.AnticipationStatusExogenous;
        inxUnanticipatedE(this.InxE) = not(this.Plan.AnticipationStatusExogenous);

        [~, unanticipatedE] = simulate.Data.splitE( ...
            this.YXEPG(:, :, page) ...
            , inxAnticipatedE ...
            , inxUnanticipatedE ...
            , this.BaseRangeColumns ...
        );

        %
        % Find columns of unanticipated shocks or unanticipated endogenized
        % shocks within the base range
        %
        inxUnanticipatedEvents = logical(sparse(1, numColumns));
        inxUnanticipatedEvents(this.BaseRangeColumns) ...
            = any(unanticipatedE(:, this.BaseRangeColumns)~=0, 1) ...
            | any(this.Plan.InxOfUnanticipatedEndogenized(:, this.Plan.BaseRangeColumns), 1);
        columnsUnanticipatedEvents = find(inxUnanticipatedEvents);

        %
        % Under some circumstances, anticipated and unanticipated shocks can be
        % mixed in one frame stretching the entire simulation horizon
        %
        this.MixinUnanticipated(page) = method(page)==methodFirstOrder && this.Plan.NumOfExogenizedPoints==0;
        if this.MixinUnanticipated(page)
           this.FrameColumns{page} = [firstColumnSimulation, lastColumnSimulation];
           return
        end

        %
        % Make sure the first frame starts in the first column
        %
        if ~any(columnsUnanticipatedEvents==firstColumnSimulation)
            columnsUnanticipatedEvents = [firstColumnSimulation, columnsUnanticipatedEvents];
        end
        columnLastAnticipatedExogenizedYX = this.Plan.ColumnLastAnticipatedExogenized;

        %
        % Determine the start column for each frame
        %
        startFrame = reshape(columnsUnanticipatedEvents, [ ], 1);

        %
        % Determine the end column for each frame
        %
        endFrame = nan(size(startFrame));
        numFrames = numel(startFrame);
        for i = 1 : numFrames
            if i==numFrames
                endFrame(i) = lastColumnSimulation;
            else
                endFrame(i) = max([columnsUnanticipatedEvents(i+1)-1, columnLastAnticipatedExogenizedYX]);
            end
            lenFrame = endFrame(i) - startFrame(i) + 1;
            minLenFrame = this.Window;
            if method(page)==methodSelective
                minLenFrame = minLenFrame + this.MaxShift;
            end
            if lenFrame<minLenFrame
                endFrame(i) = endFrame(i) + (minLenFrame - lenFrame);
            end
        end

        this.FrameColumns{page} = [startFrame, endFrame];
    end%
end%

