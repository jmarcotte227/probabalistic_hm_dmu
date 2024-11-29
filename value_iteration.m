% Value iteration function
function [policy, V] = value_iteration(rows,cols, gamma, theta, desired_s)
fill_q = 3; %3 possible fill levels (under, crit, over) => (0,1,2)
%V(s) -> size is size of S = 3^(row x col)
V = zeros(1,fill_q^(rows*cols)); % Initialize value function
%policy example: policy(1) = "add", [i,j]. gives action ("add"), and the cell
%to execute action in ([i,j]).
policy = repmat({"add",zeros(1,2)},fill_q^(rows*cols),1); % Initialize policy
actions = ["add","subtract"];
%Q(s,a) -> size is (size of S = 3^(row x col)) x (size of A = 2 x row x col)
%Q(state,i,j,add/sub)
Q = zeros(fill_q^(rows*cols), rows,cols,2); %Initialize state-action value function
A = zeros(fill_q^(rows*cols), rows,cols,2); %Initialize advantage function
diff_QA=1;
if diff_QA > theta
    for i=1:fill_q^(rows*cols) %at each state,
        state = state_id_2_state(i,rows,cols);
        for a1 = 1:2 %for each action,
            for i1=1:rows %action can happen in any cell - action space is 2xixj
                for j1=1:cols 
                    a = actions(a1); 
                    %get reward for that action, using new V
                    V_s = lookahead(state, i1, j1, a, gamma, V, desired_s);
                    Q(i,i1,j1,a1) = V_s; %update Q
                end
            end
         end
    
        %update policy
        %get max Q for the state
        Q_sqz = squeeze(Q(i,:,:,:));
        Q_max = max(Q_sqz,[],"all"); 
        Qmax_idx = Q_sqz == Q_max;
        %recall Q format: Q(state,i,jadd/sub,)
        [idx2,idx3,idx4] = ind2sub(size(Q_sqz),find(Qmax_idx));
        if length(idx2) > 1 | length(idx3)>1 | length(idx4)>1
            idx2 = idx2(1); %randsample(idx2,1);
            idx3 = idx3(1); %randsample(idx3,1);
            idx4 = idx4(1); %randsample(idx4,1);
        end

        policy{i,1} = char(actions(idx4)); %"add" or "subtract"
        policy{i,2} = [idx2,idx3]; %i,j
        %update V
        % Q_sqz(idx2,idx3,idx4)
        V(i) = Q(i,idx2,idx3,idx4);
       
        %update advantage function
        for a1 = 1:2 %for each action,
            for i1=1:rows %action can happen in any cell - action space is 2xixj
                for j1=1:cols 
                    A(i,i1,j1,a1) = Q(i,i1,j1,a1) - V(i); 
                end
            end
         end
        diff_QA = abs(max(A-Q));
    end
else
    return
end

