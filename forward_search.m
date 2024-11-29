% Performs forward search based on the included transition model and action space

actions = ["add", "sub"];

% grid state is the state of the grid
grid_state = zeros(3);

% action state is the previous action and location (vector index)
% starts at 'start' since there is no previous action
prev_action = "start";
prev_action_idx = 0;

% target grid state
desired_grid= [0, 0, 0; 2, 2, 2; 0, 2, 0];

P_under = 0.1;
P_crit = 0.7;
P_over = 0.2;

% expected outcome of each action, to be used in reward function
exp_outcome = dictionary(actions, [2,0]);

% check starting from here
prev_action = "add";
prev_action_idx = 5;
grid_state = [0,0,0;0,2,1; 0,0,0];

% check reward function
reward_func(grid_state, desired_grid, exp_outcome, prev_action, prev_action_idx, 'add', 2)
reward_func(grid_state, desired_grid, exp_outcome, prev_action, prev_action_idx, 'sub', 5)
reward_func(grid_state, desired_grid, exp_outcome, prev_action, prev_action_idx, 'sub', 8)

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
    else
        reward=0;
    end
end


% transitions will be calculated on the fly since the state space is too large
function calc_transition()
end
function [best_action, best_value] = forward_search_step(state, desired_state, gamma, depth, U, )
    best_value = inf;
    best_action = None;
    best_position = [0 0];
    
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
    s_primes = []
    % check add first
    for idx = 1:len
        % only adding if the cell is empty
        if state(idx) == 0
            s_primes = cat(3,s_primes, add_specific_action(state, idx, "under"), add_specific_action(state, idx, "crit"), add_specific_action(state,idx, "over");
    % then check sub
    for idx = 1:len
        % only subbing if the cell has something there
        if state(idx) != 0
            s_primes = cat(3,s_primes, sub_action(state, idx))
        end
    end

    % loop through possible next states using forward search to find value
    value_primes = dictionary()
    for s_prime = s_primes
        [_, value_prime] = forward_search_step(s_prime, desired_state, depth-1, U)
        value_prime = insert(value_prime, find_state_id(s_prime, dim(1), dim(2)) , value_prime)
    end
            
    % check all actions on all positions
    for a = actions
        for idx = 1:len
            


        end
    end
end
