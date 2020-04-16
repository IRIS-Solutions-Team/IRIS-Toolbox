function defineFrames(this)

numPages = this.NumOfPages;
this.Frames = cell(1, numPages);
this.MixinUnanticipated = false(1, numPages);
this.FrameDates = cell(1, numPages);
extRange = this.ExtendedRange;
startExtRange = extRange(1);

for page = 1 : this.NumOfPages

    locallyDefineFrames(this, page);

    numFrames = size(this.Frames{page}, 1);
    frameDates = nan(numFrames, 2);
    deficiency{page} = zeros(1, numFrames);
    for frame = 1 : numFrames
        startFrame = startExtRange + this.Frames{page}(frame, 1) - 1;
        endFrame = startExtRange + this.Frames{page}(frame, end) - 1;
        frameDates(frame, :) = [startFrame, endFrame];
    end
    this.FrameDates{page} = DateWrapper(frameDates);
end

checkDeficiency(this);

end%

%
% Local Functions
%


function locallyDefineFrames(this, page)
    %
    % For the PERIOD method, the frames are individual simulation periods
    %
    if this.Method(page)==solver.Method.PERIOD
        startFrame = reshape(this.BaseRangeColumns, [ ], 1);
        endFrame = reshape(this.BaseRangeColumns, [ ], 1);
        this.Frames{page} = [startFrame, endFrame];
        return
    end

    [~, unanticipatedE] = simulate.Data.splitE( ...
        this.YXEPG(this.InxE, :, page) ...
        , this.Plan.AnticipationStatusOfExogenous ...
        , this.BaseRangeColumns ...
    );

    inxUnanticipatedE = unanticipatedE~=0;
    inxUnanticipatedAny = inxUnanticipatedE | this.Plan.InxOfUnanticipatedEndogenized;
    posUnanticipatedAny = find(any(inxUnanticipatedAny, 1));
    firstColumnSimulation = this.BaseRangeColumns(1);
    lastColumnSimulation = this.BaseRangeColumns(end);

    %
    % Under some circumstances, anticipated and unanticipated shocks can be
    % mixed in one frame stretching the entire simulation horizon
    %
    this.MixinUnanticipated(page) = hereTestMixinUnanticipated( );
    if this.MixinUnanticipated(page)
       this.Frames{page} = [firstColumnSimulation, lastColumnSimulation];
       return
    end

    if ~any(posUnanticipatedAny==firstColumnSimulation)
        posUnanticipatedAny = [firstColumnSimulation, posUnanticipatedAny];
    end
    columnLastAnticipatedExogenizedYX = this.Plan.ColumnOfLastAnticipatedExogenized;

    %
    % Determine the start column for each frame
    %
    startFrame = reshape(posUnanticipatedAny, [ ], 1);

    %
    % Determine the end column for each frame
    %
    endFrame = nan(size(startFrame));
    numFrames = numel(startFrame);
    for i = 1 : numFrames
        if i==numFrames
            endFrame(i) = lastColumnSimulation;
        else
            endFrame(i) = max( ...
                [posUnanticipatedAny(i+1)-1, columnLastAnticipatedExogenizedYX] ...
            );
        end
        lenFrame = endFrame(i) - startFrame(i) + 1;
        minLenFrame = this.Window;
        if strcmpi(this.Method(page), 'Selective')
            minLenFrame = minLenFrame + this.MaxShift;
        end
        if lenFrame<minLenFrame
            endFrame(i) = endFrame(i) + (minLenFrame - lenFrame);
        end
    end

    this.Frames{page} = [startFrame, endFrame];

    return

        function flag = hereTestMixinUnanticipated( )
            if this.Method(page)==solver.Method.FIRST_ORDER ...
                && this.Plan.NumOfExogenizedPoints==0
                flag = true;
                return
            end
            flag = false;
        end%
end%

