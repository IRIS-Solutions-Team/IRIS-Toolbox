% # Model File Language #
% 
% Model file language is used to write model files. The model files are
% plain text files (saved under any filename with any extension) that
% describes the model: its equations, variables, parameters, etc. The model
% file, on the other hand, does not describe what to do with the model. To
% run the tasks you want to perform with the model, you need first to load
% the model file into Matlab using the [`model`](model/model) function. This
% function creates a model object. Then you write your own m-files using
% Matlab and IRIS functions to perform the desired tasks with the model
% object.
%
% Why do all the keywords (except pseudofunctions) start with an
% exclamation point? Why do the comments have the same style as in Matlab?
% Why do substitutions and steady-state references use the dollar sign?
% Because this way, you can get the model files syntax-highlighted in the
% Matlab editor. Syntax highlighting improves enormously the readability of
% the files, and helps understand the model more quickly. See
% [the setup instructions](setup/Contents) for more details.
%
%
% ## Categorical List of Keywords ##
%
% ### Declaring Model Names: Variables, Parameters and Shocks ###
% 
%  Keyword                    | Brief Description
%  ---------------------------|-----------------------------------------------------------------
%   !transition-variables     | List of transition variables
%   !transition-shocks        | List of transition shocks
%   !measurement-variables    | List of measurement variables
%   !measurement-shocks       | List of measurement shocks
%   !exogenous-variables      | List of exogenous variables
%   !parameters               | List of parameters
%   !dynamic-autoexog         | Definitions of variable-shock pairs to be autoexogenized-autoendogenized in dynamic simulations
%   !steady-autoexog          | Definitions of variable-parameter pairs to be autoexogenized-autoendogenized in steady-state calculations
% 
%
% __Equations__
% 
%  Keyword                    | Brief Description
%  ---------------------------|-----------------------------------------------------------------
%   !transition_equations     | Block of transition equations
%   !measurement_equations    | Block of measurement equations
%   !dtrends                  | Block of deterministic trend equations
%   !links                    | Define dynamic links
%   !revisions                | Block of steady-state revision equations
%   !reporting_equations      | Block of reporting equations
% 
%
% __Linearized and Log-Linearized Variables__
% 
%  Keyword                    | Brief Description
%  ---------------------------|-----------------------------------------------------------------
%   !log_variables            | List of log-linearised variables
%   !all_but                  | Inverse list of log-linearised variables
%
%
% __Special Operators__
% 
%  Keyword                    | Brief Description
%  ---------------------------|-----------------------------------------------------------------
%   min                       | Define loss function for optimal policy
%   !! (steady_version)       | Steady-state version of an equation
%   {...} (shift)             | Lag or lead
%   & (steady_ref)            | Reference to the steady-state level of a variable
%   =# (exact_nonlin)         | Mark equations for equation-selective nonlinear simulations
%   !ttrend                   | Linear time trend in deterministic trend equations
%
%
% __Pseudofunctions__
%
% Pseudofunctions do not start with an exclamation point.
%
%  Keyword                    | Brief Description
%  ---------------------------|-----------------------------------------------------------------
%   diff                      | First difference pseudofunction
%   dot                       | Gross rate of growth pseudofunction
%   difflog                   | First log-difference pseudofunction
%   movavg                    | Moving average pseudofunction
%   movgeom                   | Moving geometric average pseudofunction
%   movprod                   | Moving product pseudofunction
%   movsum                    | Moving sum pseudofunction
%
%
% __Preparser Commands__
% 
%  Keyword                    | Brief Description
%  ---------------------------|-----------------------------------------------------------------
%   !substitutions            | Define text substitutions
%   <...> (interp)            | Interpolation
%   !import                   | Include the content of another model file
%   !export                   | Create exportable file to be saved in working directory
%   !function                 | Create exportable m-file function to be saved in working directory
%   !if                       | Choose block of code based on logical condition
%   !switch                   | Switch among several cases based on expression
%   !for                      | For loop for automated creation of model code
%   % (line_comment)          | Line comments
%   %{...%} (block_comment)   | Block comments
%
%
% __Matlab Functions and User Functions in Model Files__
%
% You can use any of the built-in functions (Matlab functions, functions
% within the Toolboxes you have on your computer, and so on). In addition,
% you can also use your own functions (written as an m-file) as long as the
% m-file is on the Matlab search path or in the current directory.
%
% In your own m-file functions, you can also (optionally) supply the first
% derivatives that will be used to compute Taylor expansions when the model
% is being solved, and the second derivatives that will be used when
% the function occurs in a loss function.
%
% When asked for the derivatives, the function is called with two extra
% input arguments on top of that function's regular input arguments. The
% first extra input argument is a text string `'diff'` (indicating the call
% to the function is supposed to return a derivative). The second extra
% input argument is a number or a vector of two numbers; it determines with
% respect to which input argument or arguments the first derivative or the
% second derivative is requested.
%
% For instance, your function takes three input arguments, `myfunc(x,y,z)`.
% To be able to supply derivates avoiding thus numerical differentiation,
% the function must be written so that the following three calls
%
%     myfunc(x,y,z,'diff',1)
%     myfunc(x,y,z,'diff',2)
%     myfunc(x,y,z,'diff',3)
%
% return the first derivative wrt to the first, second, and third input
% argument, respectively, while
%
%     myfunc(x,y,z,'diff',[1,2])
%
% returns the second derivative wrt to the first and second input
% arguments. Note that second derivatives are only needed for functions
% that occur in an equation defining optimal policy objective,
% [min](irislang/min).
%
% If any of these calls fail, the respective derivative will be simply
% evaluated numerically.
%
%
% Basic rules IRIS model files
% -----------------------------
%
% * There can be four types of equations in IRIS models: transition equations
% which are simply the endogenous dynamic equations, measurement equations
% which link the model to observables, deterministic trend equations which
% can be added at the top of measurement equations, and dynamic links which
% can be used to link some parameters or steady-state values to each other.
%
% * There can be two types of variables and two types of shocks in IRIS
% models: transition variables and shocks, and measurement variables and
% shocks.
%
% * Each model must have at least one transition (aka endogenous)
% variable and one transition equation.
%
% * Each variable, shock, or parameter must be declared in the appropriate
% declaration section.
%
% * The declaration sections and equations sections can be written in any
% order.
%
% * You can have as many declaration sections or equations sections of the
% same kind as you wish in one model file; they all get combined together
% at the time the model is being loaded.
%
% * Transition variables can occur with lags and leads in transition
% equations. Transition variables cannot, though, have leads in measurement
% equations.
%
% * Measurement variables and the shocks cannot have any lags or leads.
%
% * Transition shocks cannot occur in measurement equations, and the
% measurement shocks cannot occur in transition equations.
%
% * Exogenous variables can only occur in dtrends (deterministic trend
% equations), and must be always supplied in the input database to commands
% like `model/simulate`, `model/jforecast`, `model/filter`,
% `model/estimate`, etc. They are not returned in the output databases.
%
% * You can choose between linearisation and log-linearisation for each
% individual transition and measurement variable. Shocks are always
% linearized. Exogenous variables must be always introduced so that their
% effect on the respective measurement variable is linear.
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team
