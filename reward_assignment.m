function R = reward_assignment(state,desired_state)
% R will be R(i,j) - take the sum of R when calculating V in value
% iteration
R = zeros(size(state));
[rows,cols] = size(state);
for i = 1:rows
    for j = 1:cols
        %get reward for correct placements
        if isequal(state,desired_state)
            R(:,:) = Inf;
            return
        end
        if state(i,j) == desired_state(i,j)
            if state(i,j) == 2
                R(i,j) = 10;
            elseif state(i,j) == 0
                R(i,j) = 5;
            end
        % else
        %     if state(i,j) > 0
        %         R(i,j) = 2;
        %     end
        end

    end
end


end