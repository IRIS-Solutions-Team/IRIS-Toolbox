function outputData = simulateFirstOrder(this, inputData, baseRange, plan, opt)
% simulateFirstOrder  Simulate first-order system
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

nv = length(this);

% Get all data from input databank
baseRange = double(baseRange);
startOfBaseRange = baseRange(1);
endOfBaseRange = baseRange(end);
[ YXEPG, ~, extendedRange, ~, ...
  maxShift, extendedTimeTrend ] = data4lhsmrhs( this, ...
                                                inputData, ...
                                                baseRange, ...
                                                'ResetShocks=', true );
startOfExtendedRange = extendedRange(1);
firstColumnOfSimulation = round(startOfBaseRange - startOfExtendedRange + 1);
lastColumnOfSimulation = round(endOfBaseRange - startOfExtendedRange + 1); 
numOfDataColumns = size(YXEPG, 2);

% Report missing initial conditions
inxOfNaNPresample = any(isnan(YXEPG(:, 1:firstColumnOfSimulation-1, :)), 3);
checkInitialConditions(this, inxOfNaNPresample, firstColumnOfSimulation);

for v = 1 : nv
    % Set up simulation @Data from @Model and @Plan and update parameters and steady trends
    vthData = simulate.Data.fromModelAndPlan(this, v, plan, YXEPG);
    vthData.FirstColumnOfSimulation = firstColumnOfSimulation;
    vthData.LastColumnOfSimulation = lastColumnOfSimulation;
    updateE(vthData);

    % Set up @Rectangular object for simulation
    vthRect = simulate.Rectangular.fromModel(this, v);
    vthRect.Deviation = opt.Deviation;
    vthRect.SimulateY = true;

    % Split simulation range into time frames
    timeFrames = splitIntoTimeFrames(vthData, plan);

    % __Switchboard__
    % Simulate @Rectangular object
    numOfTimeFrames = numel(timeFrames);
    for i = 1 : numOfTimeFrames
        setTimeFrame(vthRect, timeFrames{i});
        setTimeFrame(vthData, timeFrames{i});
        updateSwap(vthData, plan);
        ensureExpansionForData(vthRect, vthData);
        if vthData.NumOfExogenizedPoints==0
            % vthData.MixinUnanticipated = true;
            flat(vthRect, vthData);
        else
            % vthData.MixinUnanticipated = false;
            swapped(vthRect, vthData);
        end
    end

    % Set all data points in YXEPG in presample and postsample to NaN except intial conditions
    resetOutsideBaseRange(vthData, this);

    % Update output data
    YXEPG(:, :, v) = vthData.YXEPG;
end

% Convert output data to databank if requested
if strcmpi(opt.OutputData, 'Databank')
    names = this.Quantity.Name;
    labels = this.Quantity.Label;
    inxToInclude = ~getIndexByType(this.Quantity, TYPE(4));
    outputData = databank.fromDoubleArrayNoFrills( YXEPG(:, 1:lastColumnOfSimulation, :), ...
                                                   names, ...
                                                   startOfExtendedRange, ...
                                                   labels, ...
                                                   inxToInclude );
    outputData = addToDatabank('Default', this, outputData);
end

end%


%
% Local Functions
%


function timeFrames = splitIntoTimeFrames(data, plan);
    [anticipatedE, unanticipatedE] = retrieveE(data);   
    inxOfUnanticipatedE = unanticipatedE~=0;
    posOfUnanticipated = find(any( inxOfUnanticipatedE ...
                                   | plan.InxOfUnanticipatedEndogenized, 1 ));
    if ~any(posOfUnanticipated==data.FirstColumnOfSimulation)
        posOfUnanticipated = [data.FirstColumnOfSimulation, posOfUnanticipated];
    end
    lastAnticipatedExogenizedYX = plan.LastAnticipatedExogenized;
    numOfTimeFrames = numel(posOfUnanticipated);
    timeFrames = cell(1, numOfTimeFrames);
    for i = 1 : numOfTimeFrames
        startOfTimeFrame = posOfUnanticipated(i);
        if i==numOfTimeFrames
            endOfTimeFrame = data.LastColumnOfSimulation;
        else
            endOfTimeFrame = max([posOfUnanticipated(i+1)-1, lastAnticipatedExogenizedYX]);
        end
        timeFrames{i} = [startOfTimeFrame, endOfTimeFrame];
    end
end%

