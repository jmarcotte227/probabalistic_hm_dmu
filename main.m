vis_delay = 0.5;
desired_state = [0, 0, 0, 0, 0, 0, 0;
                 0, 0, 2, 2, 2, 0, 0;
                 0, 2, 0, 2, 0, 2, 0;
                 0, 2, 2, 2, 2, 2, 0;
                 0, 2, 0, 2, 0, 2, 0;
                 0, 0, 2, 2, 2, 0, 0;
                 0, 0, 0, 0, 0, 0, 0];

state = zeros(7);

[rows, cols] = size(state);
% initialize figure
figure;
visualize_state(state)
pause(vis_delay)

while ~isequal(state, desired_state)
  for i = 1:rows
    for j = 1:cols
      if state(i,j) ~= desired_state(i,j)
        if desired_state(i,j) == 0
          state = sub_action(state, [i,j]);
          visualize_state(state)
          pause(vis_delay)
        elseif desired_state(i,j) == 2
          if state(i,j) == 1
            state = sub_action(state, [i,j]);
            visualize_state(state)
            pause(vis_delay)
          end
          state = add_action(state, [i,j]);
          visualize_state(state)
          pause(vis_delay)
        end
      end
    end
  end
end
