% BVAR  Bayesian VAR Priors (BVAR Package).
%
% The BVAR package is used to create basic types of prior dummy
% observations when estimating Bayesian VAR models. The dummy observations
% are passed in the [`VAR/estimate`](VAR/estimate) function through the
% `'BVAR='` option.
%
% Constructing dummy observations
% ================================
%
% * [`covmat`](BVAR/covmat) - Covariance matrix prior dummy observations for BVARs.
% * [`litterman`](BVAR/litterman) - Litterman's prior dummy observations for BVARs.
% * [`sumofcoeff`](BVAR/sumofcoeff) - Doan et al sum-of-coefficient prior dummy observations for BVARs.
% * [`uncmean`](BVAR/uncmean) - Unconditional-mean dummy (or Sims' initial dummy) observations for BVARs.
% * [`user`](BVAR/user) - User-supplied prior dummy observations for BVARs.
%
% Weights on prior dummy observations
% ====================================
%
% The prior dummies produced by [`litterman`](BVAR/litterman),
% [`uncmean`](BVAR/uncmean), [`sumofcoeff`](BVAR/sumofcoeff) can be
% weighted up or down using the input argument `Mu`. To give the weight a
% clear interpretation, use the option `'stdize=' true` when estimating the
% VAR. In that case, setting `Mu` to `sqrt(N)` means the prior dummies are
% worth a total of extra `N` artifical observations; the weight can be
% related to the actual number of observations used in estimation.
%
% Getting help on BVAR functions
% ===============================
%
%     help BVAR
%     help BVAR/function_name
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.
