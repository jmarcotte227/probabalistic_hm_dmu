% Performs forward search based on the included transition model and action space

actions = ["add", "sub"];


% grid state is the state of the grid
grid_state = zeros(3);

% action state is the previous action and location (vector index)
% starts at 'start' since there is no previous action
prev_action = "start";
prev_action_idx = 0;

% target grid state (3,3)
desired_grid= [0, 2, 2; 
               2, 2, 2; 
               2, 2, 0];

% target grid state (4,4)
% desired_grid= [0, 2, 2, 0; 
%                2, 2, 2, 2; 
%                2, 2, 2, 2; 
%                0, 2, 2, 0];
% target grid state (5,5)
% desired_grid= [0, 0, 2, 0, 0; 
%                0, 2, 2, 2, 0; 
%                2, 2, 2, 2, 2; 
%                0, 2, 2, 2, 0];

% desired_state = [0, 0, 0, 0, 0, 0, 0;
%                  0, 0, 2, 2, 2, 0, 0;
%                  0, 2, 0, 2, 0, 2, 0;
%                  0, 2, 2, 2, 2, 2, 0;
%                  0, 2, 0, 2, 0, 2, 0;
%                  0, 0, 2, 2, 2, 0, 0;
%                  0, 0, 0, 0, 0, 0, 0];


P_under = 0.1;
P_crit = 0.7;
P_over = 0.2;

% expected outcome of each action, to be used in reward function
exp_outcome = dictionary(actions, [2,0]);

% check starting from here
prev_action = "add";
prev_action_idx = 1;
grid_state = [0,0,0;0,0,0;0,0,0];

% check reward function
% reward_func(grid_state, desired_grid, exp_outcome, prev_action, prev_action_idx, 'sub', 2)
% reward_func(grid_state, desired_grid, exp_outcome, prev_action, prev_action_idx, 'sub', 5)
% reward_func(grid_state, desired_grid, exp_outcome, prev_action, prev_action_idx, 'sub', 8)

% % check forward step 
% [action, position, value] = forward_search_step(grid_state, desired_grid, 0.9, 2, exp_outcome, prev_action, prev_action_idx, P_under, P_crit, P_over);

% reset to 0
rng("default");
prev_aciton = "add";
prev_action_idx = 1;
depth=1;
grid_state = zeros(size(desired_grid));
dimension = size(grid_state);

step_count = 0;
mat_save = grid_state;
step_times = [];
t_start = cputime();
while ~isequal(grid_state, desired_grid)
    t_start = cputime();
    [action, position, value] = forward_search_step(grid_state, desired_grid, 0.9, depth, exp_outcome, prev_action, prev_action_idx, P_under, P_crit, P_over);
    [i,j] = ind2sub(dimension, position);
    t_end = cputime();
    step_times = [step_times,t_end-t_start];
    if action == "add"
        grid_state = add_action(grid_state, [i,j]);
    elseif action == "sub"
        grid_state = sub_action(grid_state, [i,j]);
    end
    % save grid state
    mat_save = [mat_save, grid_state];
    step_count=1+step_count;
    disp(step_count)
end
t_end = cputime();
fprintf("Done\n")

%% Calculate step time

fprintf("Average Step Time: ");
disp(mean(step_times))
fprintf("\n")

fprintf("Std. Dev: ");
disp(std(step_times))
fprintf("\n")



%% Visualize State Evolution
% load("fs_data/3x3d4_state_ev.mat");
load("fs_data/4x4d1_state_ev.mat");
vis_delay = 0.5;
figure;
visualize_state(mat_save(1:4,1:4))
input('wait for start')
pause(vis_delay)
pause(vis_delay)
pause(vis_delay)
step_count=22;
for i = 1:step_count
    visualize_state(mat_save(:,i*4+1:(i+1)*4))
    pause(vis_delay)
end
pause(vis_delay)
pause(vis_delay)
pause(vis_delay)

%% Functions

function reward=reward_func(state, target_state, exp_outcome, prev_action, prev_action_idx, action, action_position)
    % calculate neighboring cells
    % no need to remove invalid elements as those will be pruned 
    % before the reward is calculated
    dimension = size(state);
    [i,j] = ind2sub(dimension, prev_action_idx);
    
    % neighbor_cells include diagonals
    neighbor_cells = [i,   j+1;
                      i,   j-1;
                      i+1, j;
                      i-1, j;
                      i+1, j+1;
                      i+1, j-1;
                      i-1, j+1;
                      i-1, j-1];    

    % neighbor_cells do not include diagonals
    neighbor_cells = [i,   j+1;
                      i,   j-1;
                      i+1, j;
                      i-1, j];

    % Current value of cell at action position 
    cur_val = state(action_position);
    des_val = target_state(action_position);
    exp_val = exp_outcome(action);
    [row,col] = ind2sub(dimension, action_position);

    % high reward for reaching terminal state
    if isequal(target_state, state)
        reward=50;
    % reward for performing actions on neighboring states that drive it towards the solution
    elseif (action == prev_action && ismember([row,col], neighbor_cells,'row') && exp_val == des_val)
        reward=10;
    % reward for performing action that drives towards the final state
    elseif exp_val == des_val
        reward=5;
    % reward for removing partially filled cells
    elseif (cur_val == 1 && action =="sub")
        reward=5;
    elseif (cur_val ==0 && action =="sub")
        reward = -100;
    else
        reward=0;
    end
end


function [best_action, best_idx, best_value] = forward_search_step(state, desired_state, gamma, depth, exp_outcome, prev_action, prev_action_position, P_under, P_crit, P_over)
    best_value = -inf;
    best_action = "none";
    best_idx = 0;
    
    % calculate size of matrix
    dim = size(state);
    len = dim(1)*dim(2);

    % return reward of zero at depth
    if depth <= 0
        best_action = "depth";
        best_value = 0;
        return
    end
    
    if isequal(state,desired_state)
        best_action = "finished";
        best_value = 50; % returning reward for reaching terminal state
        return
    end
    % Generate list of possible next states
    s_primes = [];
    % check add first
    for idx = 1:len
        [posx, posy] = ind2sub(dim,idx);
        pos = [posx,posy];
        % only adding if the cell is empty
        if state(idx) == 0
            s_primes = cat(3,s_primes, add_specific_action(state, pos, "under"), add_specific_action(state, pos, "crit"), add_specific_action(state, pos, "over"));
        end
    end
    % then check sub
    for idx = 1:len
        [posx, posy] = ind2sub(dim,idx);
        pos = [posx,posy];
        % only subbing if the cell has something there
        if state(idx) ~= 0
            s_primes = cat(3,s_primes, sub_action(state, pos));
        end
    end

    % loop through possible next states using forward search to find value
    value_primes = dictionary();
    num_s = size(s_primes);
    for k = 1:num_s(3)
        [action_prime, idx_prime, value_prime] = forward_search_step(s_primes(:,:,k), desired_state, gamma, depth-1, exp_outcome, prev_action, prev_action_position, P_under, P_crit, P_over);
        value_primes = insert(value_primes, find_state_id(s_primes(:,:,k)) , value_prime);
    end
    % checking all add conditions first
    for idx = 1:len
        [posx, posy] = ind2sub(dim,idx);
        pos = [posx,posy];
        % if position is empty
        if state(idx) == 0
            try
                summation = P_under * value_primes(find_state_id(add_specific_action(state, pos, "under"))) + P_crit * value_primes(find_state_id(add_specific_action(state, pos, "crit"))) + P_over * value_primes(find_state_id(add_specific_action(state, pos, "over")));
            catch
                find_state_id(add_specific_action(state, pos, "under"))
                find_state_id(add_specific_action(state, pos, "crit"))
                find_state_id(add_specific_action(state, pos, "over"))
                value_primes
                idx
            end
            value = reward_func(state, desired_state, exp_outcome, prev_action, prev_action_position , "add", idx) + gamma*summation;
            % check if better than best value
            if value > best_value
                best_value=value;
                best_action = "add";
                best_idx = idx;
            end
        end
    end

    for idx = 1:len
        [posx, posy] = ind2sub(dim,idx);
        pos = [posx,posy];
        if state(idx) ~= 0
            summation = value_primes(find_state_id(sub_action(state, pos)));
            value = reward_func(state, desired_state, exp_outcome, prev_action, prev_action_position, "sub", idx) + gamma*summation;
            % check if better than best value
            if value > best_value
                best_value=value;
                best_action = "sub";
                best_idx = idx;
            end
        end
    end
end
