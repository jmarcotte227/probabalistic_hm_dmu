function R = reward_assignment(state,desired_state)
% R will be R(i,j) - take the sum of R when calculating V in value
% iteration
R = zeros(size(state));
[rows,cols] = size(state);
for i = 1:rows
    for j = 1:cols
        %get reward for correct placements
        if isequal(state,desired_state)
            R(:,:) = 1000;
            return
        else
            R = 0;
        end
    end
end


end