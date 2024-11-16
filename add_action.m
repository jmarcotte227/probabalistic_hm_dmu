function state = add_action(state, position)
  % takes the add action at the designated position
  % can underfill, fill critically, or overfil with varying probabilities
  names = ["under", "crit", "over"];
  probabilities = [0.1, 0.6, 0.3];
  result = randsample(names, 1, true, probabilities);

  if result == "under" && state(position(1),position(2))~=2
    state(position(1), position(2)) = 1;
  elseif result == "crit"
    state(position(1), position(2)) = 2;
  elseif result == "over"
    state(position(1), position(2)) = 2;
    if state(position(1)+1, position(2)) == 0
      state(position(1)+1, position(2)) = 1;
    end
    if state(position(1)-1, position(2)) ==0
      state(position(1)-1, position(2)) = 1;
    end
    if state(position(1), position(2)+1) == 0
      state(position(1), position(2)+1) = 1;
    end
    if state(position(1), position(2)-1) == 0
      state(position(1), position(2)-1) = 1;
    end
  end
end