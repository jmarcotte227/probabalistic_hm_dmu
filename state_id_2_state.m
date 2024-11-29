function s = state_id_2_state(idx,rows,cols)
%get full state space
fact_size = zeros([1,rows*cols])+3; %3 instantiations (0,1,2)
full_fact = fullfact(fact_size)-1;

s = reshape(full_fact(idx,:),[2,2]);