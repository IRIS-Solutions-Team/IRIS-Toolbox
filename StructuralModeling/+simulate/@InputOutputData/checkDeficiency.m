% checkDeficiency  Check and report deficiency of simulation plans in each frame
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function checkDeficiency(this)

lastColumnSimulation = this.BaseRangeColumns(end);

numPages = this.NumPages;
deficiencyStatus = cell(1, numPages);

for page = 1 : numPages
    numFrames = size(this.FrameColumns{page}, 1);
    deficiencyStatus{page} = zeros(1, numFrames);
    for frame = 1 : numFrames
        firstColumnFrame = this.FrameColumns{page}(frame, 1);
        [inxExogenized, inxEndogenized] = ...
            getSwapsWithinFrame(this.Plan, firstColumnFrame, lastColumnSimulation);
        numExogenized = nnz(inxExogenized);
        numEndogenized = nnz(inxEndogenized);
        if numExogenized<numEndogenized
           if this.Plan.AllowUnderdetermined
               continue
           end
           deficiencyStatus{page}(frame) = -1;
        elseif numExogenized>numEndogenized
            if this.Plan.AllowOverdetermined
                continue
            end
            deficiencyStatus{page}(frame) = 1;
        end
    end
end

if nnz([deficiencyStatus{:}])==0
    return
end

report = cell.empty(1, 0);
for page = 1 : numPages
    for frame = find(deficiencyStatus{page}~=0)
        if deficiencyStatus{page}(frame)==-1
            description = 'Underdetermined';
        else
            description = 'Overdetermined';
        end
        report{end+1} = sprintf( ...
            '[Page:%g][Frame:%g]: %s', ...
            page, frame, description ...
        );
    end
end

exception.error([
    "Model:DeficientSimulationPlan" 
    "Simulation Plan is deficient in %s"
], report{:});

end%

