function this = quickAssign(this, from)

% >=R2019b
%{
arguments
    this Model
    from (1, 1) struct
end
%}
% >=R2019b


for i = 1 : numel(this.Quantity.Name(1:end-1))
    name = this.Quantity.Name{i};
    if isfield(from, name)
        this.Variant.Values(1, i, :) = from.(name);
    end
end

end%
