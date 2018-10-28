function d = clip(d, newStart, newEnd)
% clip  Clip all time series in databank to a new range
%
% __Syntax__
%
%     outputDatabank = databank.clip(inputDatabank, newStart, newEnd)
%
%
% __Input Arguments__
%
% * `inputDatabank` [ struct ] - Input databank whose time series (of the
% matching frequency) will be clipped to a new range defined by `newStart`
% and `newEnd`.
%
% * `newStart` [ DateWrapper | `-Inf` ] - A new start date to which all
% time series of the matching frequency will be clipped; `-Inf` means the
% start date will not be altered.
%
% * `newEnd` [ DateWrapper | `-Inf` ] - A new end date to which all time
% series of the matching frequency will be clipped; `Inf` means the end
% date will not be altered.
%
%
% __Output Arguments__
%
% * `outputDatabank` [ struct ] - Output databank in which all time series
% (of the matching frequency) are clipped to the new range.
%
%
% __Description__
%
%
% __Example__
%
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.clip');
    parser.addRequired('InputDatabank', @isstruct);
    parser.addRequired('NewStart', @(x) isequal(x, -Inf) || DateWrapper.validateDateInput(x));
    parser.addRequired('NewEnd', @(x) isequal(x, Inf) || DateWrapper.validateDateInput(x));
end
parser.parse(d, newStart, newEnd);

%--------------------------------------------------------------------------

isNewStartInf = isequal(newStart, -Inf);
isNewEndInf = isequal(newEnd, Inf);

if isNewStartInf && isNewEndInf
    return
end

if ~isNewStartInf
    freq = DateWrapper.getFrequencyAsNumeric(newStart);
else
    freq = DateWrapper.getFrequencyAsNumeric(newEnd);
end

listOfFields = fieldnames(d);
numberOfFields = numel(listOfFields);
for i = 1 : numberOfFields
    ithField = listOfFields{i};
    if isa(d.(ithField), 'TimeSubscriptable')
        if d.(ithField).FrequencyAsNumeric==freq
            d.(ithField) = clip(d.(ithField), newStart, newEnd);
        end
        continue
    end
    if isstruct(d.(ithField))
        d.(ithField) = databank.clip(d.(ithField), newStart, newEnd);
    end
end

end%

