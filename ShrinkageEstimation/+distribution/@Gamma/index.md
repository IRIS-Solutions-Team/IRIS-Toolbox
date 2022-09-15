
# Overivew of gamma distribution object

__Constructors__

The following are static constructors and need to be called with
`distribution.Gamma.` preceding their names.

  fromShapeScale - Gamma distribution from shape and scale parameters
  fromAlphaBeta - Gamma distribution from alpha and beta parameters
  fromMeanVar - Gamma distribution from mean and variance
  fromMeanStd - Gamma distribution from mean and std deviation
  fromModeVar - Gamma distribution from mode and variance
  fromModeStd - Gamma distribution from mode and std deviation


__Distribution Properties__

These properties are directly accessible through the distribution object,
followed by a dot and the name of a property.

  Name - Name of the distribution
  Domain - Domain of the distribution

  Alpha - Alpha (shape) parameter of Gamma distribution
  Beta - Beta (scale) parameter of Gamma distribution
  Mean - Mean (expected value) of distribution
  Var - Variance of distribution
  Std - Standard deviation of distribution
  Mode - Mode of distribution
  Median - Median of distribution
  Location - Location parameter of distribution
  Shape - Shape parameter of distribution
  Scale - Scale parameter of distribution


__Density Related Functions__

  pdf - Probability density function
  logPdf - Log of probability density function up to constant
  info - Minus second derivative of log of probability density function
  inDomain - True for data points within domain of distribution function


__Description__



