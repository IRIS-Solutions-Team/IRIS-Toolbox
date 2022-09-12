
# Overview of structural modeling tools

#### [Structural models](@Model/index.md)

Structural models are systems of dynamic simultaneous (interdependent)
equations with lags and leads (expectations). IrisT supports nonlinear
nonstationary (balanced growth path) structural models.

#### [Simulation plans](@Plan/index.md)

Simulation plans are objects used to define more complex simulation
assumptions for various types of model (structural models, explanatory
equations, vector autoregressions). They allow the user to define the
anticipation status, inversion pairs (exogenize/endogenize) and
conditioning information.

#### [Explanatory equations](@Explanatory/index.md)

Explanatory equations are systems of sequential (non-simultaneous)
equations that can be estimated and executed (simulated) one after another.
The advantage over the structural models is faster evaluation, especially
for nonlinear equations.

#### [State space systems](@LinearSystem/index.md)

Linear time-varying state-space systems can be used for designing
nontrivial Kalman fitering tasks.

#### [Nonlinear equations solver settings](Solver/index.md)

IrisT features its own nonlinear equations solver used in calculating the
steady state and dynamic simulations of structural models.

