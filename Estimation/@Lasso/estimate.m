function [XX, YY] = estimate(this, Y, X, start, endd, budget, varargin)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('Lasso.estimate');
    INPUT_PARSER.addRequired('Lasso', @(x) isa(x, 'Lasso'));
    %INPUT_PARSER.addRequired('Y', @(x) isnumeric(x) && isvector(x) && size(x, 2)==1);
    %INPUT_PARSER.addRequired('X', @(x) isnumeric(x) && ismatrix(x));
    INPUT_PARSER.addRequired('Y', @(x) isa(x, 'TimeSubscriptable'));
    INPUT_PARSER.addRequired('X', @(x) isa(x, 'TimeSubscriptable'));
    INPUT_PARSER.addRequired('Start', @(x) isa(x, 'DateWrapper'));
    INPUT_PARSER.addRequired('End', @(x) isa(x, 'DateWrapper'));
    INPUT_PARSER.addRequired('Budget', @(x) isnumeric(x) && isvector(x) && all(x>0));
    INPUT_PARSER.addParameter('A', [ ], @(x) isempty(x) || (isnumeric(x) && ismatrix(x)));
    INPUT_PARSER.addParameter('b', [ ], @(x) isempty(x) || (isnumeric(x) && isvector(x) && size(x, 2)==1));
    INPUT_PARSER.addParameter('Intercept', true, @(x) isequal(x, true) || isequal(x, false));
    INPUT_PARSER.addParameter('NonNegative', double.empty(1, 0), @(x) isempty(x) || (isnumeric(x) && isvector(x) && all(x==round(x)) && all(x>=0)));
    INPUT_PARSER.addParameter('NonPositive', double.empty(1, 0), @(x) isempty(x) || (isnumeric(x) && isvector(x) && all(x==round(x)) && all(x>=0)));
    INPUT_PARSER.addParameter('Signs', double.empty(1, 0), @(x) isempty(x) || (isnumeric(x) && isvector(x) && all(x==round(x))));
    INPUT_PARSER.addParameter('Standardize', true, @(x) isequal(x, true) || isequal(x, false));
    INPUT_PARSER.addParameter('SubjectToBudget', @all, @(x) isequal(x, @all) || (isnumeric(x) && all(x==round(x)) && (all(x<0) || all(x>0))));
end
INPUT_PARSER.parse(this, Y, X, start, endd, budget, varargin{:});
opt = INPUT_PARSER.Options;
userA = opt.A;
userB = opt.b;

if ~isempty(opt.Signs)
    opt.NonNegative = find(opt.Signs>0);
    opt.NonPositive = find(opt.Signs<0);
end

%--------------------------------------------------------------------------

Y = getData(Y, start:endd);
X = getData(X, start:endd);
numBudgets = numel(budget);
indexObservations = all(~isnan([Y, X]), 2);
YY = Y(indexObservations, :);
XX = X(indexObservations, :);
numParams = size(XX, 2);

stdXX = std(XX, 0, 1);
meanXX = mean(XX, 1);
XX = (XX - meanXX)./stdXX;
stdYY = std(YY, 0, 1);
meanYY = mean(YY, 1);
YY = (YY - meanYY)./stdYY;
if opt.Standardize
    normalizeBy = [stdXX, stdXX];
    if opt.Intercept
        normalizeBy = [normalizeBy, 1];
    end
end

if isequal(opt.SubjectToBudget, @all)
    budgetRow = ones(1, numParams);
elseif all(opt.SubjectToBudget<0)
    budgetRow = ones(1, numParams);
    exclude = opt.SubjectToBudget;
    exclude(abs(exclude)>numParams) = [ ];
    budgetRow(abs(exclude)) = 0;
elseif all(opt.SubjectToBudget>0)
    budgetRow = zeros(1, numParams);
    include = opt.SubjectToBudget;
    include(abs(include)>numParams) = [ ];
    budgetRow(include) = 1;
end
budgetRow = [budgetRow, budgetRow];

AA = [
    budgetRow
    -eye(2*numParams, 2*numParams)
];
E = [eye(numParams), -eye(numParams)];

addIntercept( ); 
nonNegativeConstraints( );
nonPositiveConstraints( );

bb = zeros(size(AA, 1), 1);
bb(1, 1) = NaN;

addUserConstraints( );

if opt.Standardize
    AA = real(AA).*normalizeBy + imag(AA);
end

f = -XX' * YY;
H = XX' * XX;

ff = E'*f;
HH = E'*H*E;

numRuns = numBudgets;

theta = nan(numParams, numRuns);
thetaNorm = nan(numParams, numRuns);
for i = 1 : numRuns
    ithAA = AA;
    ithBb = bb;
    if isinf(budget(i))
        ithAA(1, :) = [ ];
        ithBb(1, :) = [ ];
    else
        ithBb(1, 1) = budget(i);
    end
    x = quadprog(HH, ff, ithAA, ithBb);
    theta(:, i) = E*x;
    thetaNorm(1:end-1, i) = theta(1:end-1, i) ./ stdXX';
end

if ~opt.Intercept
    XX(:, end+1) = 1;
    theta(end+1, :) = 0;
end

YHat = nan(size(Y, 1), numBudgets);
YHat(indexObservations, :) = XX*theta;

this.A = AA;
this.b = bb;
this.Theta = theta;
this.ThetaNorm = theta;
this.ThetaNorm = thetaNorm;
this.Y = Series(start, Y);
this.YHat = Series(start, YHat);
this.Error = Series(start, YHat-Y);

return


    function addIntercept( )
        if ~opt.Intercept
            return
        end
        XX(:, end+1) = 1;
        AA(:, end+1) = 0;
        E(:, end+1) = 0;
        E(end+1, :) = 0;
        E(end, end) = 1;
        numParams = size(XX, 2);
    end


    function nonNegativeConstraints( )
        if isempty(opt.NonNegative)
            return
        end
        posNonNegative = opt.NonNegative;
        posNonNegative(posNonNegative>numParams) = [ ];
        posNonNegative = unique(posNonNegative);
        numNonNegative = numel(posNonNegative);
        addA = zeros(numNonNegative, numParams);
        for i = 1 : numel(posNonNegative)
            addA(i, posNonNegative(i)) = -1;
        end
        AA = [AA; addA*E];
    end


    function nonPositiveConstraints( )
        if isempty(opt.NonPositive)
            return
        end
        posNonPositive = opt.NonPositive;
        posNonPositive(posNonPositive>numParams) = [ ];
        posNonPositive = unique(posNonPositive);
        numNonPositive = numel(posNonPositive);
        addA = zeros(numNonPositive, numParams);
        for i = 1 : numel(posNonPositive)
            addA(i, posNonPositive(i)) = 1;
        end
        AA = [AA; addA*E];
    end


    function addUserConstraints( )
        if isempty(userA)
            return
        end
        if opt.Intercept && size(userA, 2)==numParams-1
            userA(:, end+1) = 0;
        end
        AA = [AA; userA*E];
        if ~isempty(userB)
            bb = [bb; userB];
        else
            bb = [bb; zeros(size(userA, 1), 1)];
        end
    end
end
