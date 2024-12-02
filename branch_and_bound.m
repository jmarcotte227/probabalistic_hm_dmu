% Performs forward search based on the included transition model and action space

actions = ["add", "sub"];
vis_delay = 0.5;

% grid state is the state of the grid
grid_state = zeros(3);

% action state is the previous action and location (vector index)
% starts at 'start' since there is no previous action
prev_action = "start";
prev_action_idx = 0;

% target grid state
desired_grid= [0, 2, 0; 2, 2, 2; 0, 2, 0];

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
global global_best_value;
global_best_value = -inf;

% expected outcome of each action, to be used in reward function
exp_outcome = dictionary(actions, [2,0]);

% check starting from here
prev_action = "add";
prev_action_idx = 1;
grid_state = [0,0,0;0,0,0; 0,0,0];

% check reward function
% reward_func(grid_state, desired_grid, exp_outcome, prev_action, prev_action_idx, 'sub', 2)
% reward_func(grid_state, desired_grid, exp_outcome, prev_action, prev_action_idx, 'sub', 5)
% reward_func(grid_state, desired_grid, exp_outcome, prev_action, prev_action_idx, 'sub', 8)

% % check forward step 
% [action, position, value] = forward_search_step(grid_state, desired_grid, 0.9, 2, exp_outcome, prev_action, prev_action_idx, P_under, P_crit, P_over);

% Value iteration
% reset to 0
prev_aciton = "add";
prev_action_idx = 1;
grid_state = zeros(3);
dimension = size(grid_state);
figure;
while ~isequal(grid_state, desired_grid)
    [action, position, value, global_best_value] = branch_and_bound_step(grid_state, desired_grid, 0.9, 2, exp_outcome, prev_action, prev_action_idx, P_under, P_crit, P_over, global_best_value);
    [i,j] = ind2sub(dimension, position);
    if action == "add"
        grid_state = add_action(grid_state, [i,j]);
    elseif action == "sub"
        grid_state = sub_action(grid_state, [i,j]);
    end
    visualize_state(grid_state)
    pause(vis_delay)
end

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
    elseif (action == prev_action & ismember([row,col], neighbor_cells,'row') & exp_val == des_val)
        reward=10;
    % reward for performing action that drives towards the final state
    elseif exp_val == des_val
        reward=5;
    % reward for removing partially filled cells
    elseif (cur_val == 1 & action =="sub")
        reward=5;
    elseif (cur_val ==0 & action =="sub")
        reward = -100;
    else
        reward=0;
    end
end


function [best_action, best_idx, best_value, global_best_value] =  branch_and_bound_step(state, desired_state, gamma, depth, exp_outcome, prev_action, prev_action_position, P_under, P_crit, P_over, global_best_value)
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
        [action_prime, idx_prime, value_prime, global_best_value] = branch_and_bound_step(s_primes(:,:,k), desired_state, gamma, depth-1, exp_outcome, prev_action, prev_action_position, P_under, P_crit, P_over,global_best_value);
        value_primes = insert(value_primes, find_state_id(s_primes(:,:,k)) , value_prime);
    end

    %First check if it should be pruned
    for idx = 1:len
        [posx, posy] = ind2sub(dim,idx);
        pos = [posx,posy]; 
        %%Not sure what this is for but needed in forward search
        try
            summation = P_under * value_primes(find_state_id(add_specific_action(state, pos, "under"))) + P_crit * value_primes(find_state_id(add_specific_action(state, pos, "crit"))) + P_over * value_primes(find_state_id(add_specific_action(state, pos, "over")));
        catch
            find_state_id(add_specific_action(state, pos, "under"));
            find_state_id(add_specific_action(state, pos, "crit"));
            find_state_id(add_specific_action(state, pos, "over"));
            value_primes;
            idx;
        end

        %Finding the Q (state action value function) (upper bounds for BaB)
        Qadd = reward_func(state, desired_state, exp_outcome, prev_action, prev_action_position , "add", idx) + gamma*summation;
        Qsub = reward_func(state, desired_state, exp_outcome, prev_action, prev_action_position, "sub", idx) + gamma*value_primes(find_state_id(sub_action(state, pos)));
        
        %If the upper bound is lower than the previous globally best value
        %skip (this should be the lowest value of the value function of a
        %previously explored action at that state, I realized I was doing
        % it incorrectly as I commented before commiting rip)
        if Qadd < global_best_value && Qsub < global_best_value
                skip = Qadd
                skip = Qsub                
                continue; %prune
        end

        %I'm gonna be honest this may be incorrect due to the whole not
        %doing the lower bound correctly thing. Also I'm not the best at
        %understanding the recursiveness to make sure it is correct but
        %this is just determining the best action and value
        if Qadd > Qsub
                best_value= Qadd;
                best_action = "add";
                best_idx = idx;
                if best_value > global_best_value
                    global_best_value = best_value
                    return
                end
        end
        if Qsub > Qadd
                best_value= Qsub;
                best_action = "sub";
                best_idx = idx;
                if best_value > global_best_value
                    global_best_value = best_value
                    return
                end
        end
    end
end
