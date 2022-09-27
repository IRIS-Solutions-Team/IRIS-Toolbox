%{
% 
% # Overview of structural model objects
% 
% {==
% Structural models are systems of dynamic simultaneous (interdependent)
% equations with lags and leads (expectations). IrisT supports nonlinear
% nonstationary (balanced growth path) structural models.
% ==}
% 
% ## Categorical list of functions 
% 
% 
% ### Constructing model objects 
% 
% Function | Description 
% ---|---
% [`Model.fromFile`](fromFile.md) | Create new Model object from model source file(s)
% [`Model.fromSnippet`](fromSnippet.md) | Create new Model object from snippet of code within m-file
% [`Model.fromString`](fromString.md) | Create new Model object from string array
% 
% 
% ### Getting information about models
% 
% Function | Description 
% ---|---
% [`access`](access.md) | Access properties of Model objects
% [`beenSolved`](beenSolved.md) | True if first-order solution has been successfully calculated
% [`byAttributes`](byAttributes.md) | Look up model quantities and equation by attributes
% [`findEquation`](findEquation.md) | Find equations whose input strings pass one or more tests
% [`getBounds`](getBounds.md) | Get lower and upper bounds imposed on model quantities
% [`isLinear`](isLinear.md) | True if the model has been declared as linear
% [`isLinkActive`](isLinkActive.md) | True if dynamic link is active
% [`isLog`](isLog.md) | True for variables declared as log-variables
% [`print`](print.md) | Print model object
% [`solutionMatrices`](solutionMatrices.md) | Access first-order state-space (solution) matrices
% [`subsref`](subsref.md) | Subscripted reference for Model objects
% [`table`](table.md) | Create table based on selected indicators from Model object
% [`isnan`](isnan.md) | Check for NaNs in model object.
% [`isempty`](isempty.md) | True for empty model object
% 
% 
% ### Assigning values within models
% 
% Function | Description 
% ---|---
% [`assign`](assign.md) | Assign parameters, steady states, std deviations or cross-correlations
% [`assignFromModel`](assignFromModel.md) | Assign model quantities from another model
% [`replaceNames`](replaceNames.md) | Replace model names with some other names
% [`reset`](reset.md) | Reset specific values within model object
% [`resetBounds`](resetBounds.md) | Reset lower and upper bounds imposed on model quantities
% [`setBounds`](setBounds.md) | Set bounds for model quantities
% [`rescaleStd`](rescaleStd.md) | Rescale all std deviations by the same factor
% 
% 
% ### Analytical properties of models
% 
% Function | Description 
% ---|---
% [`analyticGradients`](analyticGradients.md) | Evaluate analytic/symbolic derivatives of model equations
% [`blazer`](blazer.md) | Analyze sequential block structure of steady equations
% [`eig`](eig.md) | Eigenvalues of model transition matrix
% [`systemMatrices`](systemMatrices.md) | First-order system matrices describing the unsolved model
% [`isstationary`](isstationary.md) | True if the model or a linear combination of its variables is stationary
% 
% 
% ### Stochastic properties of models
% 
% Function | Description 
% ---|---
% [`acf`](acf.md) | Autocovariance and autocorrelation function for model variables
% [`fevd`](fevd.md) | Forecast error variance decomposition for model variables.
% [`ffrf`](ffrf.md) | Filter frequency response function of transition variables to measurement variables
% [`fisher`](fisher.md) | Approximate Fisher information matrix in frequency domain
% [`fmse`](fmse.md) | Forecast mean square error matrices.
% 
% 
% ### Solving and simulating models 
% 
% Function | Description 
% ---|---
% [`checkSteady`](checkSteady.md) | Check if equations hold for currently assigned steady-state values
% [`checkInitials`](checkInitials.md) | Check if databank contains all initial conditions for simulation
% [`expand`](expand.md) | Compute forward expansion of model solution for anticipated shocks
% [`simulate`](simulate.md) | Run a model simulation
% [`solve`](solve.md) | Calculate first-order solution matrices
% [`steady`](steady.md) | Compute steady state or balance-growth path of the model
% [`system`](system.md) | System matrices for the unsolved model
% [`lhsmrhs`](lhsmrhs.md) | Discrepancy between the LHS and RHS of each model equation for given data
% 
% 
% ### Estimating and filtering model quantities
% 
% Function | Description 
% ---|---
% [`bn`](bn.md) | Beveridge-Nelson trends
% [`estimate.md`](estimate.md) | Estimate model parameters by maximizing posterior-based objective function
% [`kalmanFilter`](kalmanFilter.md) | Kalman smoother and estimator of out-of-likelihood parameters
% 
% 
% ### Manipulating the structure of models
% 
% Function | Description 
% ---|---
% [`activeLink`](activateLink.md) | Activate dynamic links for selected LHS names
% [`deactiveLink`](deactivateLink.md) | Deactivate dynamic links for selected LHS names
% [`alter`](alter.md) | Expand or reduce number of parameter variants in model object
% [`changeGrowthStatus`](changeGrowthStatus.md) | Change growth status of the model
% [`changeLinearStatus`](changeLinearStatus.md) | Change linear status of model
% [`changeLogStatus`](changeLogStatus.md) | Change log status of model variables
% [`horzcat`](horzcat.md) | Merge two or more compatible model objects into multiple parameterizations
% 
% 
%}
% --8<--


