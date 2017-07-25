function [f, outp] = kalman(this, d, range, varargin)

TYPE = @int8;

opt = passvalopt('model.kalman', varargin{:});

range = range(1) : range(end);
y = datarequest('y', this, d, range, ':', 'NaN');

last = find(any(any(~isnan(y),1),2), 1, 'last');
last = max([1, last]);
y = y(:, :, 1:last);
nAnt = size(y, 3)-1;
if nAnt>0
    this = expand(this, nAnt);
end

[nx, nb] = size(this.solution{1});
nf = nx - nb; %#ok<NASGU>

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% s = this.Solution{1};
% s = struct( );
s = model.Solution( );
s.T = this.solution{1};
s.R = this.solution{2};
s.k = this.solution{3};
s.Z = this.solution{4};
s.H = this.solution{5};
s.d = this.solution{6};
s.U = this.solution{7};
s.StdCorr = this.Variant{1}.StdCorr;
s.StateVec = this.Vector.Solution{2};
s.NUnit = sum(this.Variant{1}.Stability==TYPE(1));
% s.DIFFUSE_SCALE = 1e8;
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

range = range(1) : range(end);
[ny, nxx, nb, nf, ne] = sizeOfSolution(this); %#ok<ASGLU>
inp = kalman.InpData( );
inp.y = y;
inp.Range = range;
if isstruct(opt.InitMedian)
    inp.aInit = datarequest('init', this, opt.InitMedian, range, ':', 'NaN');
    inp.PaInit = zeros(nb);
elseif strcmpi(opt.InitMedian, 'InputData')
    inp.aInit = datarequest('init', this, d, range, ':', 'NaN');
    inp.PaInit = zeros(nb);
end

outp = kalman.OutpData( );
outp.StorePredict = true;
outp.StoreFilter = true;
outp.StoreSmooth = true;
outp.NAhead = nAnt; % opt.NAhead;
outp.StoreAhead = outp.NAhead>0;
outp.RescaleVar = opt.RescaleVar;
outp.Range = range;
prealloc(outp, s, inp);

kalman.initialize(s, inp, outp, opt);
kalman.forward(s, inp, outp);
kalman.backward(s, inp, outp);
f = kalman.results(outp, this.Quantity, s);

end
