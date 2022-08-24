
% >=R2019b
%{
function this = replaceData(this, pairs)

arguments
    this Series
end

arguments (Repeating)
    pairs
end
%}
% >=R2019b


% <=R2019a
%(
function this = replaceData(this, varargin)

pairs = varargin;
%)
% <=R2019a


if isempty(this.Data)
    return
end

for i = 1 : numel(pairs)
    this.Data(this.Data==pairs{i}(1)) = pairs{i}(2);
end

this = trim(this);

end%

