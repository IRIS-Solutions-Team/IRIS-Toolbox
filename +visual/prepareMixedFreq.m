function prepareMixedFreq(axesHandle)

if nargin<1
    axesHandle = gca( );
end

for a = reshape(axesHandle, 1, [ ])
    setappdata(a, 'IRIS_PositionWithinPeriod', 'Middle');
    hold(a, 'on');
end

end%

