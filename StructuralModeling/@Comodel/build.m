function this = build(this, varargin)

this = build@Model(this, varargin{:});

%
% Assign default costds
%
DEFAULT_COSTD = 1;
posCostds = this.Pairing.Costds;
posCostds = posCostds(posCostds>0);
for p = reshape(posCostds, 1, [])
    x = this.Variant.Values(1, p, :);
    x(isnan(x)) = DEFAULT_COSTD;
    this.Variant.Values(1, p, :) = x;
end % for

end%

