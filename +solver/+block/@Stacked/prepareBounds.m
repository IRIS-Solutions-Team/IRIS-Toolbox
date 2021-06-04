function prepareBounds(this)

numQuantities = numel(this.IdQuantities);
ptrs = reshape(real(this.IdQuantities), 1, [ ]);
uniquePtrs = unique(ptrs);
boundsWithinModel = this.ParentBlazer.Model.Quantity.Bounds(1:2, :);

%
% All bounds are [-Inf, Inf]; return immediately an empty array
%
if all(all(isinf(boundsWithinModel(1:2, uniquePtrs))))
    for i = 1 : numel(this.SolverOptions)
        this.SolverOptions(i).Bounds = [ ];
    end
    return
end

namesWithinModel = this.ParentBlazer.Model.Quantity.Name;
inxLogWithinModel = reshape(this.ParentBlazer.Model.Quantity.InxLog, 1, [ ]);
namesInvalidUpper = string.empty(1, 0);
if any(inxLogWithinModel(uniquePtrs))
    for ptr = uniquePtrs
        if ~inxLogWithinModel(ptr)
            continue
        end
        bounds__ = boundsWithinModel(:, ptr);
        if ~isequal(bounds__(1), -Inf)
            if bounds__(1)>0
                bounds__(1) = log(bounds__(1));
            else
                bounds__(1) = -Inf;
            end
        end
        if ~isequal(bounds__(2), Inf)
            if bounds__(2)>0
                bounds__(2) = log(bounds__(2));
            else
                namesInvalidUpper(end+1) = namesWithinModel(ptr);
            end
        end
        boundsWithinModel(:, ptr) = bounds__;
    end
end

if ~isempty(namesInvalidUpper)
    hereReportNamesInvalidUpper( );
end

for i = 1 : numel(this.SolverOptions)
    this.SolverOptions(i).Bounds = boundsWithinModel(:, ptrs);
end

return

    function hereReportNamesInvalidUpper( )
        %(
        exception.error([
            "Solver:InvalidUpperLog"
            "Upper bounds for quantities declared as log-variables must be positive numbers. "
            "The upper bound for this quantity is negative: %s "
        ], namesInvalidUpper);
        %)
    end%
end%

