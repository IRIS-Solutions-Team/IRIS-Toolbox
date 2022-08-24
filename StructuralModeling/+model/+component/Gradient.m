
classdef Gradient
    methods (Static)
        function out = loadobj(in)
            out = model.Gradient();
            for n = reshape(string(fieldnames(in)), 1, []);
                out.(n) = in.(n);
            end
        end%
    end
end

