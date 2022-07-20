function outputVAR = VAR(this, select, range, varargin)
% VAR  Population VAR for selected model variables.
%
% ## Syntax ##
%
%     V = VAR(M, List, Range, ...)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Solved model object.
%
% * `List` [ cellstr | char ] - List of variables selected for the VAR.
%
% * `Range` [ numeric | char ] - Hypothetical range, including pre-sample
% initial condition, on which the VAR would be estimated.
%
%
% ## Output Arguments ##
%
% * `V` [ VAR ] - Asymptotic reduced-form VAR for selected model variables.
%
%
% ## Options ##
%
% * `'Order='` [ numeric | *1* ] - Order of the VAR.
%
% * `'Constant='` [ *`true`* | `false` ] - Include in the VAR a constant
% vector derived from the steady state of the selected variables.
%
%
% ## Description ##
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Parse required arguments.
pp = inputParser( );
pp.addRequired('List', @(x) ischar(x) || iscellstr(x));
pp.addRequired('Range', @validate.date);
pp.parse(List, range);


%(
isnumericscalar = @(x) isnumeric(x) && isscalar(x);
defaults = { 
    'acf', { }, @(x) iscell(x) && iscellstr(x(1:2:end))
    'order', 1, isnumericscalar
    'constant, const', true, @(x) isequal(x, true) || isequal(x, false)
};
%)

% Parse options.
opt = passvalopt(defaults, varargin{:});

% Convert char list to cellstr.
if ischar(select)
    select = regexp(select, ...
        '[a-zA-Z][\w\(\)\{\}\+\-]*', 'match');
end

%--------------------------------------------------------------------------

nv = length(this);
nz = length(select);
p = opt.order;
C = acf(this, opt.acf{:}, 'order', p, 'output', 'numeric');
range = range(1) : range(end);
nPer = length(range);
nk = double(opt.constant);

% Find the position of selected variables in the sspace vector and in the
% model names.
[posSpace, posName] = myfindsspacepos(this, select, '-error');

C = C(posSpace, posSpace, :, :);
ixLog = this.Quantity.IxLog(1, posName);

% TODO: Calculate Sigma.
outputVAR = VAR( );
outputVAR.A = nan(nz, nz*p, nv);
outputVAR.K = zeros(nz, nv);
outputVAR.Omega = nan(nz, nz, nv);
outputVAR.Sigma = [ ];
outputVAR.G = nan(nz, 0, nv);
outputVAR.Range = range;
outputVAR.IxFitted = true(1, nPer);
outputVAR.IxFitted(1:p) = false;
outputVAR.NHyper = nz*(nk+p*nz);

for v = 1 : nv
    Ci = C(:, :, :, v);
    zBar = this.Variant.Values(:, posName, v);
    zBar = transpose(zBar);
    zBar(ixLog) = log(zBar(ixLog));
    
    % __Moment Matrices__
    % M1 := [C1, C2, ...]
    M1 = reshape(Ci(:, :, 2:end), nz, nz*p);
    
    % M0 := [C0, C1, ...; C1', C0, ... ]
    % First, produce M0' : = [C0, C1', ...; C1, C0, ...].
    M0t = [ ];
    for i = 0 : p-1
        M0t = [M0t; ...
            nan(nz, nz*i), reshape(Ci(:, :, 1:p-i), nz, nz*(p-i)) ...
            ]; %#ok<AGROW>
    end
    M0 = M0t.';
    nanInx = isnan(M0t);
    M0t(nanInx) = M0(nanInx); %#ok<AGROW>
    % Then, tranpose M0' to get M0.
    M0 = M0t.';
    
    % __Transition Matrix__
    Ai = M1 / M0;
    
    % __Cov Matrix of Errors__
    Omgi = Ci(:, :, 1) - M1*Ai.' - Ai*M1.' + Ai*M0*Ai.';
    
    % __Vector of Constants__
    Ki = zeros(size(zBar));
    if opt.constant
        Ki = sum(polyn.var2polyn(Ai), 3)*zBar;
    end
    
    % __Populate VAR Properties__
    outputVAR.A(:, :, v) = Ai;
    outputVAR.K(:, v) = Ki;
    outputVAR.Omega(:, :, v) = Omgi;
end

% Assign variable names
outputVAR.EndogenousNames = select; 

% Create residual names automatically
outputVAR.ResidualNames = @auto;

% Compute triangular representation
outputVAR = schur(outputVAR);

% Populate AIC and SBC criteria
outputVAR = infocrit(outputVAR);

end
