function rect = prepareRectangular(this, rect)

rect.Quantity = this.Quantity;
rect.Vector = this.Vector;

[~, maxShift] = getActualMinMaxShifts(this);
rect.HasLeads = maxShift>0;

end%

