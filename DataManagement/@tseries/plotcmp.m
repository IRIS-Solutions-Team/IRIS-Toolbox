function [Ax,Lhs,Rhs,varargout] = plotcmp(varargin)

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

if isnumeric(varargin{1})
   Range = varargin{1};
   varargin(1) = [ ];
else
   Range = Inf;
end

X = varargin{1};
varargin(1) = [ ];
X.data = X.data(:,:);
if size(X.data,2) < 2
   utils.error('tseries:plotcmp', ...
      'The function plotcmp( ) requires multicolumn input time series.');
end


%(
defaults = { 
    'compare', [-1;1], @isnumeric
    'cmpcolor, diffcolor', [1, 0.75, 0.75], @(x) isnumeric(x) && length(x)==3 && all(x>=0) && all(x<=1)
    'baseline', true, @(x) isequal(x, true) || isequal(x, false)
    'rhsplotfunc', [ ], @(x) isempty(x) || isequal(x, @bar) || isequal(x, @area) 
    'cmpplotfunc, diffplotfunc', @bar, @(x) isequal(x, @bar) || isequal(x, @area)
};
%)


[opt,varargin] = passvalopt(defaults, varargin{:});


if ~isempty(opt.rhsplotfunc)
    opt.compareplotfunc = opt.rhsplotfunc;
end

%--------------------------------------------------------------------------

X.data = X.data(:,:);
nx = size(X.data,2);
opt.compare = opt.compare(:);
nCmp = length(opt.compare);
if nx > nCmp
    opt.compare(end+1:nx,1) = 0;
elseif nx < nCmp
    opt.compare(nx+1:end,1) = [ ];
end
d = replace(X,X.data * opt.compare,X.start);

[Ax,Lhs,Rhs,varargout{1:nargout-3}] = ...
   plotyy(Range,X,Range,d,varargin{:},'rhsPlotFunc',opt.cmpplotfunc);

set(Rhs,'faceColor',opt.cmpcolor,'edgeColor',opt.cmpcolor);

if ~opt.baseline
    h = get(Rhs,'BaseLine');
    delete(h);
end

set(Ax(1),'tag','plotcmpLhs');
set(Ax(2),'tag','plotcmpRhs');

end

