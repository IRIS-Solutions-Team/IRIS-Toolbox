function [shift, rows, power] = prepareChange(this, varargin)
% prepareChange  Prepare options for time change functions
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('@NumericTimeSubscriptable/prepareChange');
    addRequired(pp, 'inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    addOptional(pp, 'shift', -1, @(x) validate.roundScalar(x) || validate.anyString(x, 'YoY', 'EoPY', 'BoY'));
    addParameter(pp, 'OutputFreq', [ ], @(x) isempty(x) || isa(Frequency(x), 'Frequency'));
end
parse(pp, this, varargin{:});
shift = pp.Results.shift;
opt = pp.Options;

%--------------------------------------------------------------------------

inputFreq = DateWrapper.getFrequencyAsNumeric(this.Start);
[shift, rows] = hereResolveShift(shift);
power = hereResolvePower( );

return


    function [shift, rows] = hereResolveShift(shift)
        if inputFreq==0 && validate.anyString(shift, 'YoY', 'BoY', 'EoPY')
            thisError = [
                "NumericTimeSubscriptable:IncompatibleInputs"
                "Time shift cannot be specified as 'YoY', 'BoY', or 'EoPY' "
                "for time series of INTEGER date frequency."
            ];
            throw(exception.Base(thisError, 'error'));
        elseif strcmpi(shift, 'YoY')
            shift = -inputFreq;
            rows = [ ];
        elseif strcmpi(shift, 'EoPY')
            shift = [ ];
            rows = hereResolveRows(0);
        elseif strcmpi(shift, 'BoY')
            shift = [ ];
            rows = hereResolveRows(-1);
        else
            shift = double(shift);
            rows = [ ];
        end

        return

            function rows = hereResolveRows(offset)
                [~, periods] = dat2ypf(this.Range);
                periods = reshape(periods, 1, [ ]) + offset;
                numPeriods = numel(periods);
                rows = round(reshape(1:numPeriods, 1, [ ]) - periods);
                rows(rows<1) = NaN;
            end%
    end%




    function power = hereResolvePower( )
        power = 1;
        if ~isempty(opt.OutputFreq)
            if isempty(shift)
                thisError = [ 
                    "NumericTimeSubscriptable:IncompatibleInputs"
                    "Annualized changes or option OutputFreq= cannot be combined "
                    "with the time shift specified as 'BoY' or 'EoPY'."
                ];
                throw(exception.Base(thisError, 'error'));
            end
            power = inputFreq / double(opt.OutputFreq) / abs(shift);
        end
    end%
end%
