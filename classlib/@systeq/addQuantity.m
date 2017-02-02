function this = addQuantity(this, type, varargin)

%--------------------------------------------------------------------------

nAdd = length(varargin);

this.Quantity.Type = [this.Quantity.Type, repmat(type, 1, nAdd)];

this.Quantity.Name = [this.Quantity.Name, varargin];
this.Quantity.Label = [this.Quantity.Label, repmat({''}, 1, nAdd)];
this.Quantity.Alias = [this.Quantity.Alias, repmat({''}, 1, nAdd)];
this.Quantity.IxLog = [this.Quantity.IxLog, false(1, nAdd)];
this.Quantity.IxLagrange = [this.Quantity.IxLagrange, false(1, nAdd)];
this.Quantity.Bounds = [this.Quantity.Bounds, repmat(this.Quantity.DEFAULT_BOUNDS, 1, nAdd)];

end