
function this = add(this, inputString)

% >=R2019b
%{
arguments
    this
    inputString (1, :) string 
end
%}
% >=R2019b


    this.Charts = [this.Charts, textual.stringify(inputString)];

end%

