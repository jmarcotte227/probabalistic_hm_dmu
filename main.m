close all;
clear all;


vis_delay = 0.5;
% desired_state = [0, 0, 0, 0, 0, 0, 0;
%                  0, 0, 2, 2, 2, 0, 0;
%                  0, 2, 0, 2, 0, 2, 0;
%                  0, 2, 2, 2, 2, 2, 0;
%                  0, 2, 0, 2, 0, 2, 0;
%                  0, 0, 2, 2, 2, 0, 0;
%                  0, 0, 0, 0, 0, 0, 0];
% 
% state = zeros(7);

% desired_state = [0 2 0;
%                  2 0 2;
%                  0 2 0];
% 
% state = zeros(3);

desired_state = [2,0;2,0];
state = zeros(2);

[rows, cols] = size(state);
% initialize figure
figure;
visualize_state(state)
pause(vis_delay)

%define parameters
gamma = 0.9; 
theta = 1e-12;
% depth = 3;

[optimal_policy, optimal_value] = value_iteration(rows,cols, gamma, theta, desired_state); %added theta

%% implement value iteration
writerObj = VideoWriter('test7.avi'); %// initialize the VideoWriter object
open(writerObj);
c = 1;
while ~isequal(state, desired_state)
  idx = find_state_id(state);
  action = optimal_policy{idx,1}; 
  ij = optimal_policy{idx,2};
  i=ij(1);
  j=ij(2);
  if action == "add"
      state = add_action(state, [i,j]);
  else
      state = sub_action(state, [i,j]); %subtractive action
  end
  visualize_state(state)
  pause(vis_delay)
  F(c:c+20) = getframe ;           %// Capture the frame
  c = c+20;
  if isequal(state,desired_state)
      break
  end
end
writeVideo(writerObj,F)

close(writerObj);












