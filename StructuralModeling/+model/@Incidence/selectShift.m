function this = selectShift(this, shiftFrom, shiftTo)

[~, numOfQuantities, ~] = size(this);

positionFrom = find(this.Shift==shiftFrom);
if isempty(positionFrom)
    positionFrom = 1;
end

if nargin<3
    shiftTo = shiftFrom;
    positionTo = positionFrom;
else
    positionTo = find(this.Shift==shiftTo);
    if isempty(positionTo)
        positionTo = length(this.Shift);
    end
end

this.Matrix = this.Matrix(:, ((positionFrom-1)*numOfQuantities+1) : (positionTo*numOfQuantities));
this.Shift = shiftFrom : shiftTo;

end%

