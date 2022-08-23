classdef EquationUnderConstruction ...
    < model.Insertable

    properties
        LhsDynamic = cell.empty(1, 0)
        RhsDynamic = cell.empty(1, 0)
        SignDynamic = cell.empty(1, 0)
        LhsSteady = cell.empty(1, 0)
        RhsSteady = cell.empty(1, 0)
        SignSteady = cell.empty(1, 0)

        MaxShDynamic = double.empty(1, 0);
        MinShDynamic = double.empty(1, 0);
        MaxShSteady = double.empty(1, 0);
        MinShSteady = double.empty(1, 0);
    end


    methods
        % function this = move(this, fromPos, toPos)
            % listProperties = properties(this);
            % numProperties = numel(listProperties);
            % reorder = 1 : numel(this.(listProperties{1}));
            % reorder(fromPos) = [ ];
            % reorder = [ reorder(1:toPos-1), fromPos, reorder(toPos:end) ];
            % for i = 1 : numProperties
                % ithProperty = listProperties{i};
                % this.(ithProperty) = this.(ithProperty)(reorder);
            % end
        % end%


        % function this = insert(this, add, ixPre, ixPost)
            % x = metaclass(this);
            % ix = ~[ x.PropertyList.Dependent ] & ~[ x.PropertyList.Constant ];
            % lsProp = { x.PropertyList(ix).Name };
            % pivot = lsProp{1};
            % numOld = numel(this.(pivot));
            % numToAdd = numel(add.(pivot));
            % numNew = numOld + numToAdd;
            % for i = 1 : numel(lsProp)
                % prop = lsProp{i};
                % this.(prop) = [ ...
                    % this.(prop)(:, ixPre), ...
                    % add.(prop), ...
                    % this.(prop)(:, ixPost) ...
                % ];
                % if size(this.(prop), 2)~=numNew
                    % throw( exception.Base('General:Internal', 'error') );
                % end
            % end
        % end%
    end


    methods (Static)
        function this = forLoss(input)
            this.LhsDynamic = {char.empty(1, 0)};
            this.RhsDynamic = {char(input)};
            this.SignDynamic = {char.empty(1, 0)};
            this.LhsSteady = {char.empty(1, 0)};
            this.RhsSteady = {char.empty(1, 0)};
            this.SignSteady = {char.empty(1, 0)};

            this.MaxShDynamic = 0;
            this.MinShDynamic = 0;
            this.MaxShSteady = 0;
            this.MinShSteady = 0;
        end%
    end
end

