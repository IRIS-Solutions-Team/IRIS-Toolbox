function this = resetBounds(this)

    numQuantities = numel(this.Name);
    this.Bounds(:, :) = repmat(this.DEFAULT_BOUNDS, 1, numQuantities);

end%

