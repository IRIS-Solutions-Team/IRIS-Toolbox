function v = VAR(this, select, range, varargin)
% VAR  Population VAR for selected model variables.
%
% __Syntax__
%
%     V = VAR(M, List, Range, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Solved model object.
%
% * `List` [ cellstr | char ] - List of variables selected for the VAR.
%
% * `Range` [ numeric | char ] - Hypothetical range, including pre-sample
% initial condition, on which the VAR would be estimated.
%
%
% __Output Arguments__
%
% * `V` [ VAR ] - Asymptotic reduced-form VAR for selected model variables.
%
%
% __Options__
%
% * `'Order='` [ numeric | *1* ] - Order of the VAR.
%
% * `'Constant='` [ *`true`* | `false` ] - Include in the VAR a constant
% vector derived from the steady state of the selected variables.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% Parse required arguments.
pp = inputParser( );
pp.addRequired('List', @(x) ischar(x) || iscellstr(x));
pp.addRequired('Range', @DateWrapper.validateDateInput);
pp.parse(List, range);

% Parse options.
opt = passvalopt('model.VAR', varargin{:});

% Convert char list to cellstr.
if ischar(select)
    select = regexp(select, ...
        '[a-zA-Z][\w\(\)\{\}\+\-]*', 'match');
end

if ischar(range)
    range = textinp2dat(range);
end

%--------------------------------------------------------------------------

nAlt = length(this);
nz = length(select);
p = opt.order;
C = acf(this, opt.acf{:}, 'order=', p, 'output=', 'numeric');
range = range(1) : range(end);
nPer = length(range);
nk = double(opt.constant);

% Find the position of selected variables in the sspace vector and in the
% model names.
[posSpace, posName] = myfindsspacepos(this, select, '-error');

C = C(posSpace, posSpace, :, :);
ixLog = this.Quantity.IxLog(1, posName);

% TODO: Calculate Sigma.
v = VAR( );
v.A = nan(nz, nz*p, nAlt);
v.K = zeros(nz, nAlt);
v.Omega = nan(nz, nz, nAlt);
v.Sigma = [ ];
v.G = nan(nz, 0, nAlt);
v.Range = range;
v.IxFitted = true(1, nPer);
v.IxFitted(1:p) = false;
v.NHyper = nz*(nk+p*nz);

for iAlt = 1 : nAlt
    Ci = C(:, :, :, iAlt);
    zBar = this.Variant{iAlt}.Quantity(1, posName).';
    zBar(ixLog) = log(zBar(ixLog));
    
    % Put together moment matrices.
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
    
    % Compute transition matrix.
    Ai = M1 / M0;
    
    % Estimate cov matrix of residuals.
    Omgi = Ci(:, :, 1) - M1*Ai.' - Ai*M1.' + Ai*M0*Ai.';
    
    % Calculate constant vector.
    Ki = zeros(size(zBar));
    if opt.constant
        Ki = sum(polyn.var2polyn(Ai), 3)*zBar;
    end
    
    % Populate VAR properties.
    v.A(:, :, iAlt) = Ai;
    v.K(:, iAlt) = Ki;
    v.Omega(:, :, iAlt) = Omgi;
end

% Assign variable names.
v = myynames(v, select);

% Create residual names automatically.
v = myenames(v, [ ]);

% Compute triangular representation.
v = schur(v);

% Populate AIC and SBC criteria.
v = infocrit(v);

end
