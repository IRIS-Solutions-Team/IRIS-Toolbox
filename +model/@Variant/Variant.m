classdef Variant
    properties
        Name = NaN
        IsActive = true
        Quantity
        StdCorr
        Solution
        Expand
        IxInit
        Eigen
        Stability
    end
    
    
    
    
    methods
        function this = Variant(qty, vec, nExpand, nh, std)
            if nargin==0
                return
            end
            TYPE = @int8;
            nQty = length(qty);
            ixe = qty.Type==TYPE(31) | qty.Type==TYPE(32);
            [~, ~, ~, ~, ne] = sizeOfSolution(vec);
            ixg = qty.Type==TYPE(5);
            this.Quantity = nan(1, nQty);
            % Steady state of shocks cannot be changed from 0+0i.
            this.Quantity(ixe) = 0;
            % Steady state of exogenous variables preset to zero, but can be changed.
            this.Quantity(ixg) = model.DEFAULT_STEADY_EXOGENOUS;
            % Steady state of ttrend cannot be changed from 0+1i.
            ixTtrend = strcmp(qty.Name, model.RESERVED_NAME_TTREND);
            this.Quantity(ixTtrend) = model.STEADY_TTREND;
            this.StdCorr = zeros(1, ne+ne*(ne-1)/2);
            if isnumericscalar(std) && std>=0
                this.StdCorr(1, 1:ne) = std;
            end
            this.Solution = struct( );
            this = resetTransition(this, vec, nExpand, nh);
            this = resetMeasurement(this, vec);
        end
        
        
        
        
        function this = resetTransition(this, vec, nExpand, nh)
            TYPE = @int8;
            [ny, nxi, nb, ~, ne, ng] = sizeOfSolution(vec);
            [~, kxi, ~, ~] = sizeOfSystem(vec);
            this.Solution.T = nan(nxi, nb);
            this.Solution.R = nan(nxi, ne*(1+nExpand));
            this.Solution.k = nan(nxi, 1);
            this.Solution.Z = nan(ny, nb);
            this.Solution.U = nan(nb, nb);
            this.Solution.Y = nan(nxi, nh*(1+nExpand)); % Addfactors in hash signed equations.
            this.Solution.W = nan(nxi, ng); % Exogenous variables.
            
            this.Eigen = nan(1, kxi);
            this.Stability = repmat(TYPE(0), 1, kxi);
            this.IxInit = false(1, nb);
        end
        
        
        
        
        function this = resetMeasurement(this, vec)
            [ny, ~, nb, ~, ne, ng] = sizeOfSolution(vec);
            this.Solution.Z = nan(ny, nb);
            this.Solution.H = nan(ny, ne);
            this.Solution.d = nan(ny, 1);
            this.Solution.Zb = nan(ny, nb);
            this.Solution.V = nan(ny, ng); % Exogenous variables.
        end




        function sx = combineStdCorr(this, userStdCorr, nPer)
            thisStdCorr = this.StdCorr(:);
            ixUserStdCorr = ~isnan(userStdCorr);
            if any(ixUserStdCorr(:))
                lastUser = max(1, size(userStdCorr, 2));
                sx = repmat(thisStdCorr, 1, lastUser);
                sx(ixUserStdCorr) = userStdCorr(ixUserStdCorr);
                % Add model StdCorr if the last user-supplied data point is before
                % the end of the sample.
                if size(sx, 2)<nPer
                    sx = [sx, thisStdCorr];
                end
            else
                sx = thisStdCorr;
            end
        end
    end
    
    
    
    
    methods (Static)
        function vv = assignQuantity(vv, pos, vecAlt, value)
            if isempty(vv)
                return
            end
            if isequal(vecAlt, ':')
                vecAlt = 1 : numel(vv);
            elseif islogical(vecAlt)
                vecAlt = find(vecAlt);
            end
            % Get 1-length(pos)-length(vecAlt) matrix.
            x = model.Variant.getQuantity(vv, pos, vecAlt);
            x(1, :, :) = value;
            for i = 1 : numel(vecAlt)
                iAlt = vecAlt(i);
                vv{iAlt}.Quantity(pos) = x(1, :, i);
            end
        end
        
        
        
        
        function vv = assignStdCorr(vv, pos, vecAlt, value)
            if isempty(vv)
                return
            end
            if isequal(vecAlt, ':')
                vecAlt = 1 : numel(vv);
            elseif islogical(vecAlt)
                vecAlt = find(vecAlt);
            end
            % Get 1-length(pos)-length(vecAlt) matrix.
            x = model.Variant.getStdCorr(vv, pos, vecAlt);
            x(1, :, :) = value;
            for i = 1 : numel(vecAlt)
                iAlt = vecAlt(i);
                vv{iAlt}.StdCorr(pos) = x(1, :, i);
            end
        end
        
        
        
        
        function x = getQuantity(vv, pos, vecAlt)
            % Return 1-length(pos)-length(vecAlt) matrix.
            if isempty(vv)
                x = [ ];
                return
            end
            if islogical(vecAlt)
                vecAlt = find(vecAlt);
            end
            if (isnumericscalar(vecAlt) && isfinite(vecAlt)) ...
                    || length(vv)==1
                x = vv{vecAlt}.Quantity(1, pos);
            else
                x = cellfun( ...
                    @(v) v.Quantity(1, pos), ...
                    vv(vecAlt), ...
                    'UniformOutput', false ...
                    );
                x = cat(3, x{:});
            end
        end
        
        
        
        
        function x = getStdCorr(vv, pos, vecAlt)
            % Return 1-length(pos)-length(vecAlt) matrix.
            if isempty(vv)
                x = [ ];
                return
            end
            if islogical(vecAlt)
                vecAlt = find(vecAlt);
            end
            if (isnumericscalar(vecAlt) && isfinite(vecAlt)) ...
                    || length(vv)==1
                x = vv{vecAlt}.StdCorr(1, pos);
            else
                x = cellfun( ...
                    @(v) v.StdCorr(1, pos), ...
                    vv(vecAlt), ...
                    'UniformOutput', false ...
                    );
                x = cat(3, x{:});
            end
        end
        
        
        
        
        function x = getAllStd(vv, vecAlt)
            if isempty(vv)
                x = [ ];
                return
            end
            ne = size(vv{1}.Solution.H, 2);
            if islogical(vecAlt)
                vecAlt = find(vecAlt);
            end
            if (isnumericscalar(vecAlt) && isfinite(vecAlt)) ...
                    || length(vv)==1
                x = vv{vecAlt}.StdCorr(1, 1:ne);
            else
                x = cellfun( ...
                    @(v) v.StdCorr(1, 1:ne), ...
                    vv(vecAlt), ...
                    'UniformOutput', false ...
                    );
                x = cat(3, x{:});
            end
        end
        
        
        
        
        function x = getAllCorr(vv, vecAlt)
            if isempty(vv)
                x = [ ];
                return
            end
            ne = size(vv{1}.Solution.H, 2);
            if islogical(vecAlt)
                vecAlt = find(vecAlt);
            end
            if (isnumericscalar(vecAlt) && isfinite(vecAlt)) ...
                    || length(vv)==1
                x = vv{vecAlt}.StdCorr(1, ne+1:end);
            else
                x = cellfun( ...
                    @(v) v.StdCorr(1, ne+1:end), ...
                    vv(vecAlt), ...
                    'UniformOutput', false ...
                    );
                x = cat(3, x{:});
            end
        end




        function ixActive = getIxActive(vv)
            ixActive = cellfun(@(x) x.IsActive, vv);
        end
        
        
        
        
        function x = get(vv, prop, vecAlt)
            x = cellfun(@(v) v.(prop), vv(vecAlt), 'UniformOutput', false);
            x = cat(3, x{:});
        end
    end
end
