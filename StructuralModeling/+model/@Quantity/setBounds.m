% setBounds  Set level and change bounds for quantities
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = setBounds(this, varargin)

if isempty(varargin)
    return
end

if isstruct(varargin{1})
    for n = keys(varargin{1});
        this = setBounds(this, n, varargin{1}.(n));
    end
    return
end

names = varargin(1:2:end);
ell = lookup(this, varargin(1:2:end));

inxValid = reshape(~isnan(ell.PosName), 1, [ ]);
if any(~inxValid)
    exception.error([
        "Quantity:InvalidName"
        "This is not a valid name in the Model object: %s"
    ], string(names(~inxValid)));
end

inputValues = cellfun(@(x) reshape(x(1:min(end,4)), [ ], 1), varargin(2:2:end), 'uniformOutput', false);
for i = find(inxValid)
    value = model.Quantity.DEFAULT_BOUNDS;
    value(1:numel(inputValues{i})) = inputValues{i};
    this.Bounds(:, ell.PosName(i)) = value;
end

end%

