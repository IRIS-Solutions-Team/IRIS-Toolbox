
classdef Behavior
    methods (Static)
        function out = loadobj(in)
            out = model.Behavior();
            for n = reshape(string(fieldnames(in)), 1, []);
                out.(n) = in.(n);
            end
        end%
    end
end

