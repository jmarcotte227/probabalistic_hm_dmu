% Value iteration function
function [policy, V] = value_iteration(rows,cols, gamma, theta, desired_s)
fill_q = 3; %3 possible fill levels (under, crit, over) => (0,1,2)
%V(s) -> size is size of S = 3^(row x col)
V = zeros(1,fill_q^(rows*cols)); % Initialize value function
%policy example: policy(1) = "add", [i,j]. gives action ("add"), and the cell
%to execute action in ([i,j]).
policy = repmat({"add",zeros(1,2)},fill_q^(rows*cols),1); % Initialize policy
actions = ["add","subtract"];

%% create Q map
%Q(state,add/sub,i,j)
Qkeys = {};
Qvals = {};
Avals = {};
i0 = 1;
for id1 = 1:fill_q^(rows*cols)
    for id2 = 1:2
        for id3 = 1:rows
            for id4 = 1:cols
                Qkeys{i0} = [sprintf('%05d', id1), num2str(id2), num2str(id3), num2str(id4)];
                Qvals{i0} = 0;
                Avals{i0} = 1;
                i0 = i0+1;
            end
        end
    end
end
Q = containers.Map(Qkeys,Qvals); %Initialize state-action value function
A = containers.Map(Qkeys,Avals); %Initialize advantage function
disp("Q initialized")

%initialize convergence condition
diff_QA=theta*10;
iters = 0;
%% start iteration
while diff_QA > theta %or iters < 100 
    A_prev = cell2mat(values(A));
    start_iter = tic;
    for i=1:fill_q^(rows*cols) %at each state,
        state = state_id_2_state(i,rows,cols); 
        for i1=1:rows %action can happen in any cell - action space is 2xixj
            for j1=1:cols 
                for a1 = 1:2 %for each action,
                    a = actions(a1); 
                    %get value for that action, using new V
                    V_s = lookahead(state, i1, j1, a, gamma, V, desired_s);
                    % update Q map
                    Qkey = [sprintf('%05d', i),num2str(a1),num2str(i1),num2str(j1)];
                    Q(Qkey) = V_s; 
                end
            end
         end
    
        %% update policy
        % get max Q for the state
        % sort map by value (ascending order)
        [~, keys_map, values_map] = sort_map(Q); 
        %isolate keys starting with i as a 5-element char (i corresponds to state)
        first_el_match = startsWith(keys_map,num2str(sprintf('%05d', i)));
        first_el_match_locations = find(first_el_match);
        %get the largest value & its key (already sorted, so just grab the last one)
        max_idx = first_el_match_locations(end); 
        max_q = values_map(max_idx);
        max_key = keys_map{max_idx};
        
        %get the idx's from the key 
        maxi4 = str2double(max_key(end));
        maxi3 = str2double(max_key(end-1));
        maxi2 = str2double(max_key(end-2));
        maxi1 = max_key(1:end-3); %keep as char

        %update policy
        policy{i,1} = char(actions(maxi2)); %"add" or "subtract"
        policy{i,2} = [maxi3,maxi4]; %i,j
        
        %update V
        V(i) = max_q;
       
        %update advantage function
        for a1 = 1:2 %for each action,
            for i1=1:rows %action can happen in any cell - action space is 2xixj
                for j1=1:cols 
                    A_key = [maxi1,num2str(a1),num2str(i1),num2str(j1)];
                    A(A_key) = Q(A_key) - max_q; %I don't think this A is correct
                end
            end
        end
    end
    %get the change in A over the iteration (to see if theta condition is met)
    Aallval = cell2mat(values(A));
    subqa = Aallval-A_prev;
    
    diff_QA = max(abs(subqa))
    iters = iters + 1
    toc(start_iter)
end

