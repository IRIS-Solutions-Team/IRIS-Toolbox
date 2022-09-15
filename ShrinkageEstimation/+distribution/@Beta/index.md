
# Overview of beta distribution object

__Constructors__

The following are static constructors and need to be called with
`distribution.Beta.` preceding their names.

  fromAB - Beta distribution from parameters A and B
  fromMeanVar - Beta distribution from mean and variance
  fromMeanStd - Beta distribution from mean and std deviation
  fromModeVar - Beta distribution from mode and variance
  fromModeStd - Beta distribution from mode and std deviation


__Distribution Properties__

These properties are directly accessible through the distribution object,
followed by a dot and the name of a property.

  Name - Name of the distribution
  Domain - Domain of the distribution

  A - Parameter A of Beta distribution
  Beta - Beta distribution object
  Mean - Mean (expected value) of distribution
  Var - Variance of distribution
  Std - Standard deviation of distribution
  Mode - Mode of distribution
  Median - Median of distribution
  Location - Location parameter of distribution
  Scale - Scale parameter of distribution


__Density Related Functions__

  pdf - Probability density function
  logPdf - Log of probability density function up to constant
  info - Minus second derivative of log of probability density function
  inDomain - True for data points within domain of distribution function


__Description__


