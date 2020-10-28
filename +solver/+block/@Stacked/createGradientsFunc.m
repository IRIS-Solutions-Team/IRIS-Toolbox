function createGradientsFunc(this)

gradients = this.Gradients(1, :);

%
% Anonymous function to evaluate all equations in the common Jacobian
% (initial evaluation); returns an array
% 
% [eqtn2-column1-wrt1; eqtn2-column1-wrt2], [eqtn2-column2-wrt1; eqtn2-column2-wrt2]
% [eqtn2-column1-wrt1; eqtn2-column1-wrt2], [eqtn2-column2-wrt1; eqtn2-column2-wrt2]
% ...
%
% with each equation producing a different number of derivatives, and not
% all of them actually used.
%

func = cellfun(@(x) extractAfter(string(char(x)), ")"), gradients);
func = join(func, ";");
func = string(vectorize(func));
func = str2func(this.PREAMBLE + "[" + func + "]");
this.StackedJacob_GradientsFunc = func;


%
% Anynomous function to update the equations in an existing Jacobian that
% actually do change in each iteration (i.e. the function depends on a
% quantity included in this block). Create this function only if it would
% be different from the baseline StackedJacob_GradientsFunc; this is
% indicated by accelerateUpdate==true.
%

func = [ ];
needsUpdate = any(this.StackedJacob_InxNeedsUpdate);
accelerateUpdate = ~all(this.StackedJacob_InxNeedsUpdate);
if needsUpdate && accelerateUpdate 
    func = cellfun( ...
        @(x) extractAfter(string(char(x)), ")") ...
        , gradients(this.StackedJacob_InxNeedsUpdate) ...
    );
    func = join(func, ";");
    func = string(vectorize(func));
    func = str2func(this.PREAMBLE + "[" + func + "]");
end
this.StackedJacob_GradientsFunc_Update = func;

end%

