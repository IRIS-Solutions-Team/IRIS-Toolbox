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
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.clip');
    addRequired(pp, 'InputDatabank', @validate.databank);
    addRequired(pp, 'NewStart', @(x) isequal(x, -Inf) || DateWrapper.validateDateInput(x));
    addRequired(pp, 'NewEnd', @(x) isequal(x, Inf) || DateWrapper.validateDateInput(x));
end
parse(pp, d, newStart, newEnd);

%--------------------------------------------------------------------------

isNewStartInf = isequal(newStart, -Inf);
isNewEndInf = isequal(newEnd, Inf);

if isNewStartInf && isNewEndInf
    return
end

if ~isNewStartInf
    freq = dater.getFrequency(newStart);
else
    freq = dater.getFrequency(newEnd);
end

listFields = fieldnames(d);
numFields = numel(listFields);
for i = 1 : numFields
    name__ = listFields{i};
    field__ = d.(char(name__));
    if isa(field__, 'TimeSubscriptable')
        if isequaln(freq, NaN) || field__.FrequencyAsNumeric==freq
            field__ = clip(field__, newStart, newEnd);
        end
    elseif validate.databank(field__);
        field__ = databank.clip(field__, newStart, newEnd);
    end
    d.(name__) = field__;
end

end%

