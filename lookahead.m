function [V_s] = lookahead(s, i,j, a, gamma, V, desired_s)
%transition model from s to s'
T = state_transition(s,a);
%reward for s (grid of row x col cells, each cell has a reward)
R = reward_assignment(s,desired_s);

V_uniq = zeros(1,3);
state_prob = zeros(1,3);
for k=1:3 %each result of action (underfill, crit fill, overfill)
    sp = T{i,j,k};
    %new state is sp{1}
    %probability is sp{2}
    state_prob(k) = sp{2}; %P(s'|s,a)
    %find the idx # assigned to s' (V is a list)
    state_id = find_state_id(sp{1});
    V_uniq(k) = V(state_id); %V(s')
end
%reward for state = sum of rewards for each cell
V_s = sum(R,"all") + gamma*sum(state_prob.*V_uniq);
end