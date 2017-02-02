function this = selectShift(this, fromShift, toShift)

[~, nQuan, ~] = size(this);
posFrom = find(this.Shift==fromShift);
if isempty(posFrom)
    posFrom = 1;
end
posTo = find(this.Shift==toShift);
if isempty(posTo)
    posTo = length(this.Shift);
end

this.Matrix = this.Matrix(:, ((posFrom-1)*nQuan+1) : (posTo*nQuan));
this.Shift = fromShift : toShift;

end
