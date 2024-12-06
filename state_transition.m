function T = state_transition(state, action)
[rows,cols] = size(state);
if action == "add" %add action
    names = ["under", "crit", "over"];
    probabilities = [0.1, 0.7, 0.2];
    
    %have to account for an add action occuring at any cell
    %row, col, number of possible results

    T = cell(rows, cols, 3);
    for i = 1:rows
        for j=1:cols
            if state(i,j) == 0 %if cell is empty, perform add action
                for k = 1:3 %3 options for result
                    result = names(k);
                    sp = add_specific_action(state, [i,j], result);
                    T{i,j,k} = {sp, probabilities(k)};
                end
            else %if cell not empty, state doesn't change
                probabilities = [1 0 0];
                for k = 1:3
                    T{i,j,k} = {state,probabilities(k)};
                end
            end
        end
    end
                
else %subtract action
    probabilities = [1 0 0];
    %have to account for an add action occuring at any cell
    T = cell(rows, cols, 3);
    for i = 1:rows
        for j=1:cols
            if state(i,j) > 0 %if cell is not empty, perform subtract action
                for k=1:3
                    sp = sub_action(state, [i,j]);
                    T{i,j,k} = {sp, probabilities(k)};
                end
            else %if cell is empty, state doesn't change
                probabilities = [1 0 0];
                for k = 1:3
                    T{i,j,k} = {state,probabilities(k)};
                end
            end
        end
    end
end
end