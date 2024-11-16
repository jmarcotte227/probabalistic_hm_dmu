function state = sub_action(state, position)
  % deterministic, so will just return the state with the position removed
  state(position(1),position(2)) = 0;
end
