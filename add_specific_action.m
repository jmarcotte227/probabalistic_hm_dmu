%% needed for state_transition.m
function state = add_specific_action(state, position, result)
  % takes the add action at the designated position, with specified result
  if result == "under" && state(position(1),position(2))~=2
    state(position(1), position(2)) = 1;
  elseif result == "crit"
    state(position(1), position(2)) = 2;
  elseif result == "over"
    state(position(1), position(2)) = 2;
    %check existance of bordering cell
    if position(1)+1 <= size(state,1)
        %if bordering cell is empty
        if state(position(1)+1, position(2)) == 0
          %underfill bordering cell
          state(position(1)+1, position(2)) = 1;
        end
    end
    %repeat for all bordering cells
    if position(1)-1 > 0
        if state(position(1)-1, position(2)) == 0
          state(position(1)-1, position(2)) = 1;
        end
    end
    if position(2)+1 <= size(state,2)
        if state(position(1), position(2)+1) == 0
          state(position(1), position(2)+1) = 1;
        end
    end
    if position(2)-1 > 0
        if state(position(1), position(2)-1) == 0
          state(position(1), position(2)-1) = 1;
        end
    end
  end
end