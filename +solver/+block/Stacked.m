classdef Stacked < solver.block.Block
    properties
        Rectangular
        MaxLead = 0
    end


    properties (Constant)
        VECTORIZE = true;
    end


    methods
        function this = Stacked(varargin)
            this = this@solver.block.Block(varargin{:});
        end
        
        
        function [exitStatus, error] = run(this, data, t, ixLog, rect)
            exitStatus = true;
            error = struct( ...
                'EvaluatesToNan', [ ] ...
                );
            
            if isempty(this.PosQty)
                return
            end
            numOfEquationsInBlock = numel(this.PosEqn);
            numOfColumnsSimulated = numel(t);
            firstColumn = t(1);
            lastColumn = t(end);

            % Create linear index of unkowns in data
            inc = false(size(data.YXEPG));
            inc(this.PosQty, t) = true;
            linx = find(inc(:));

            % Create index of logs within linx
            inc(:) = false(size(data.YXEPG));
            inc(ixLog, :) = true;
            linxLog = inc(linx);
            clear inc

            runFotc = this.Type==solver.block.Type.SOLVE && this.MaxLead>0 && ~isempty(rect);

            if this.Type==solver.block.Type.SOLVE
                % __Solve__
                % Initialize endogenous quantities.
                z0 = data.YXEPG(linx);
                %ixNan = isnan(z0);
                %if any(any(ixNan))
                %    z0(ixNan) = data.YXEPG(posx(ixNan), t-1);
                %end
                ixNan = isnan(z0);
                if any(ixNan)
                    z0(ixNan) = 1;
                end
                % Transform initial conditions for log variables before we check bounds;
                % bounds are in logs for log variables.
                z0(linxLog) = log( z0(linxLog) );
                %* Make sure init conditions are within bounds.
                %* Empty bounds if all are Inf.
                %* Bounds are in logs for log variables.
                % checkBoundsOnInitCond( );
                % Test all equations in this block for NaNs and Infs.
                checkObjective = objective(z0);
                checkObjective = reshape(checkObjective, numOfEquationsInBlock, numOfColumnsSimulated);
                indexOfInvalidData = ~isfinite(checkObjective);
                if any(indexOfInvalidData(:))
                    indexOfInvalidEquationsInBlock = any(indexOfInvalidData, 2);
                    error.EvaluatesToNan = this.PosEqn(indexOfInvalidEquationsInBlock);
                    return
                end
                [z, exitStatus] = solve(this, @objective, z0);
                z(linxLog) = exp( z(linxLog) );
                data.YXEPG(linx) = z;
            else
                % __Assign__
                [z, exitStatus] = assign( );
            end
            
            exitStatus = all(isfinite(z)) && double(exitStatus)>0;
            
            return
            
            
            function [z, exitStatus] = assign( )
                % __Assignment__
                isInvTransform = ~isempty(this.Type.InvTransform);
                for i = 1 : numOfColumnsSimulated
                    z = this.EquationsFunc(data.YXEPG, t(i), data.L);
                    if isInvTransform
                        z = this.Type.InvTransform(z);
                    end
                    data.YXEPG(linx(i)) = z;
                end
                exitStatus = all(isfinite(data.YXEPG(linx)));
            end
            
            
            function y = objective(z, ithJacob)
                if nargin<2
                    ithJacob = [ ];
                end
                z = real(z);
                if any(linxLog)
                    z(linxLog) = exp( z(linxLog) );
                end
                data.YXEPG(linx) = z;
                
                if runFotc
                    firstColumn = t(end)+1;
                    lastColumn = t(end)+this.MaxLead;
                    deviation = false;
                    flat(rect, data, firstColumn, lastColumn, deviation);
                end

                y = this.EquationsFunc(data.YXEPG, t, data.L);
                %if isempty(ithJacob)
                %    y = this.EquationsFunc(data.YXEPG, t, data.L);
                %else
                %    y = this.NumericalJacobFunc{ithJacob}(data.YXEPG, t, data.L);
                %end
                y = y(:);
            end
        end
    end
    
    
    methods       
        function prepareBlock(this, blz, opt)
            prepareBlock@solver.block.Block(this, blz, opt);
            findMaxLead(this, blz);
        end


        function findMaxLead(this, blz)
            inc = blz.Incidence.FullMatrix(this.PosEqn, this.PosQty, :);
            last = find(any(any(inc, 1), 2), 1, 'last');
            sh0 = blz.Incidence.PosOfZeroShift;
            this.MaxLead = max(0, last-sh0);
        end
    end
end
