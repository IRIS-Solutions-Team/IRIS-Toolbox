function outputDatabank = simulateFirstOrder(this, inputDatabank, baseRange, plan, opt)
% simulateFirstOrder  Simulate first-order system
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

inxOfYX = this.Quantity.Type==TYPE(1) | this.Quantity.Type==TYPE(2);
inxOfE = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
inxOfLogInModel = this.Quantity.IxLog;
posOfYX = find(inxOfYX);
nv = length(this);
ok = true(1, nv);

% Get all data from input databank
baseRange = double(baseRange);
startOfBaseRange = baseRange(1);
endOfBaseRange = baseRange(end);
[ YXEPG, ~, extendedRange, ~, ...
  maxShift, extendedTimeTrend ] = data4lhsmrhs( this, ...
                                                inputDatabank, ...
                                                baseRange, ...
                                                'ResetShocks=', true );
startOfExtendedRange = extendedRange(1);
firstColumnToRun = round(startOfBaseRange - startOfExtendedRange + 1);
lastColumnToRun = round(endOfBaseRange - startOfExtendedRange + 1); 
columnsToRun = firstColumnToRun : lastColumnToRun;
numOfDataColumns = size(YXEPG, 2);

% Report missing initial conditions
inxOfNaNPresample = any(isnan(YXEPG(:, 1:firstColumnToRun-1, :)), 3);
checkInitialConditions(this, inxOfNaNPresample, firstColumnToRun);

for v = 1 : nv
    % Set up simulation @Data from @Model and @Plan and update parameters and steady trends
    vthData = simulate.Data.fromModelAndPlan(this, v, plan, YXEPG, firstColumnToRun);

    % Set up @Rectangular object for simulation
    vthRect = simulate.Rectangular.fromModel(this, v);
    vthRect.Deviation = opt.Deviation;
    vthRect.SimulateY = true;

    % __Switchboard__
    % Simulate @Rectangular object
    vthRect.FirstColumn = firstColumnToRun;
    vthRect.LastColumn = lastColumnToRun;
    vthRect.TimeFrame = 1;
    vthData.FirstColumn = firstColumnToRun;
    vthData.LastColumn = lastColumnToRun;
    vthData.TimeFrame = 1;
    updateExogenizedEndogenizedTarget(vthData, plan);
    retrieveE(vthData);
    ensureExpansionForData(vthRect, vthData);
    if plan.NumOfExogenizedPoints==0
        vthData.MixinUnanticipated = true;
        flat(vthRect, vthData);
    else
        vthData.MixinUnanticipated = false;
        swapped(vthRect, vthData);
    end

    % Set all data points in presample to NaN except intial conditions
    resetOutsideBaseRange(vthData, firstColumnToRun, lastColumnToRun);

    % Update output data
    YXEPG(:, :, v) = vthData.YXEPG;
end

YXEPG = YXEPG(:, 1:lastColumnToRun, :);
names = this.Quantity.Name;
labels = this.Quantity.Label;
inxToInclude = ~getIndexByType(this.Quantity, TYPE(4));
outputDatabank = databank.fromDoubleArrayNoFrills( YXEPG, ...
                                                   names, ...
                                                   startOfExtendedRange, ...
                                                   labels, ...
                                                   inxToInclude );

outputDatabank = addToDatabank('Default', this, outputDatabank);

end%

