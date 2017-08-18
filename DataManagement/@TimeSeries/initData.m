function this = initData(this, inpTime, inpData)

sizeInpData = size(inpData);
ndimsInpData = numel(sizeInpData);

if isempty(inpTime) || isnad(inpTime)
    this.Start = Date.empty(inpTime);
    ref = cell(1, ndimsInpData);
    ref{1} = [ ];
    ref(2:end) = {':'};
    this.Data = inpData(ref{:});
    this.MissingValue = TimeSeries.getDefaultMissingValue(inpData);
    return
end

if numel(inpTime)==1
    if size(inpData, 1)==0
        inpTime = inpTime([ ], :);
    end
    this.Start = inpTime;
    this.Data = inpData;
    this.MissingValue = TimeSeries.getDefaultMissingValue(inpData);
    return
end

[pos, start] = positionOf(inpTime);

nTime = numel(pos);
maxPos = max(pos);
if sizeInpData(1)==1
    rep = ones(1, ndimsInpData);
    rep(1) = nTime;
    inpData = repmat(inpData, rep);
end
this.Start = start;
sizeInpData(1) = maxPos;
missing = TimeSeries.getDefaultMissingValue(inpData);
this.Data = repmat(missing, sizeInpData);
ref = cell(1, ndimsInpData);
ref{1} = pos;
ref(2:end) = {':'};
this.Data(ref{:}) = inpData;
this.MissingValue = TimeSeries.getDefaultMissingValue(inpData);

end
