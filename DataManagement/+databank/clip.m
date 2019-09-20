function d = clip(d, newStart, newEnd)
% clip  Clip all time series in databank to a new range
%{
% ## Syntax ##
%
%     outputDatabank = databank.clip(inputDatabank, newStart, newEnd)
%
%
% ## Input Arguments ##
%
% __`inputDatabank`__ [ struct | Dictionary ] - 
% Input databank whose time series (of the matching frequency) will be
% clipped to a new range defined by `newStart` and `newEnd`.
%
% __`newStart`__ [ DateWrapper | `-Inf` ] - 
% A new start date to which all time series of the matching frequency will
% be clipped; `-Inf` means the start date will not be altered.
%
% __`newEnd`__ [ DateWrapper | `-Inf` ] - 
% A new end date to which all time series of the matching frequency will be
% clipped; `Inf` means the end date will not be altered.
%
%
% ## Output Arguments ##
%
% __`outputDatabank`__ [ struct | Dictionary ] - 
% Output databank in which all time series (of the matching frequency) are
% clipped to the new range.
%
%
% ## Description ##
%
%
% ## Example ##
%
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.clip');
    parser.addRequired('InputDatabank', @validate.databank);
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

listFields = fieldnames(d);
numberOfFields = numel(listFields);
for i = 1 : numberOfFields
    ithName = listFields{i};
    ithField = getfield(d, ithName);
    if isa(ithField, 'TimeSubscriptable')
        if isequaln(freq, NaN) || ithField.FrequencyAsNumeric==freq
            ithField = clip(ithField, newStart, newEnd);
        end
    elseif validate.databank(ithField);
        ithField = databank.clip(ithField, newStart, newEnd);
    end
    d = setfield(d, ithName, ithField);
end

end%

