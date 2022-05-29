function plot(this, Ax)
% plot  Draw highlight objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

x = this.location;

if isempty(this.location) ...
        || ~(isnumeric(x) || (iscell(x) && all(cellfun(@isnumeric, x))))
    return
end

zCoor = cell.empty(1, 0);
if isfield(this.options, 'zcoor')
    zCoor = {'ZCoor', this.options.zcoor};
end

visual.highlight( ...
    Ax, this.location, ...
    zCoor{:}, ...
    'caption', this.caption, ...
    'vPosition', this.options.vposition, ...
    'hPosition', this.options.hposition ...
);

%{
grfun.highlight(Ax, this.location, ...
    'caption', this.caption, ...
    'vPosition', this.options.vposition, ...
    'hPosition', this.options.hposition);
%}

end
