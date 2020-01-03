% logdist  Probability Distributions (logdist Package).
%
% The logdist package gives quick access to basic univariate distributions,
% and in particular to functions proportional to the logarithm of those
% basic distributions. Its primary use is setting up priors in the
% [`model/estimate`](model/estimate) and [`poster/arwm`](poster/arwm)
% functions.
%
% The logdist package is called to create function handles that have
% several different modes of use. The primary use is to compute values that
% are proportional to the log of the respective density. In addition, the
% function handles also give you access to extra information (such as the
% the proper p.d.f., the name, mean, std dev, mode, and stuctural
% parameters of the distribution), and to a random number generator from
% the respective distribution.
%
% Logdist methods:
%
% Getting function handles for univariate distributions
% ======================================================
%
% * [`chisquare`](logdist/chisquare) - Create function proportional to log of Chi-Squared distribution.
% * [`normal`](logdist/normal) - Create function proportional to log of Normal distribution.
% * [`lognormal`](logdist/lognormal) - Create function proportional to log of log-normal distribution.
% * [`beta`](logdist/beta) - Create function proportional to log of beta distribution.
% * [`gamma`](logdist/gamma) - Create function proportional to log of gamma distribution.
% * [`invgamma`](logdist/invgamma) - Create function proportional to log of inv-gamma distribution.
% * [`t`](logdist/t) - Create function proportional to log of Student T distribution.
% * [`uniform`](logdist/uniform) - Create function proportional to log of uniform distribution.
%
% Calling the logdist function handles
% =====================================
%
% The function handles `F` created by the logdist package functions can be
% called the following ways:
%
% * Get a value proportional to the log-density of the respective
% distribution at a particular point; this call is used within the
% [posterior simulator](poster/Contents):
%
%     y = F(x)
%
% * Get the density of the respective distribution at a particular point:
%
%     y = F(x,'pdf')
%
% * Get the characteristics of the distribution -- mean, std deviation,
% mode, and information (the inverse of the second derivative of the log
% density):
%
%     m = F([ ],'mean')
%     s = F([ ],'std')
%     o = F([ ],'mode')
%     i = F([ ],'info')
%
% * Get the underlying "structural" parameters of the respective
% distribution:
%
%     a = F([ ],'a')
%     b = F([ ],'b')
%
% * Get the name of the distribution (the names correspond to the function
% names, i.e. can be either of `'normal'`, `'lognormal'`, `'beta'`,
% `'gamma'`, `'invgamma'`, `'uniform'`):
%
%     name = F([ ],'name')
%
% * Draw a vector or matrix of random numbers from the distribution;
% drawing from beta, gamma, and inverse gamma requires the Statistics
% Toolbox:
%
%     a = F([ ],'draw',1,1000);
%
%     size(a)
%     ans =
%            1        10000
%
% Getting on-line help on logdist functions
% ==========================================
%
%     help logdist
%     help logdist/function_name
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.
