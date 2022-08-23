
classdef D2S
    methods (Static)
        function out = loadobj(in)
            out = model.D2S();
            for n = reshape(string(fieldnames(in)), 1, []);
                out.(n) = in.(n);
            end
        end%
    end
end

