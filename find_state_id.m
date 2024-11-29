function idx = find_state_id(s)

[rows,cols] = size(s);
%reshape s into a row
s = reshape(s,[1,rows*cols]);
%create full factorial (all possible states)
fact_size = zeros([1,rows*cols])+3; %3 instantiations (0,1,2)
full_fact = fullfact(fact_size)-1;

[Lia, Locb] = ismember(s, full_fact,"rows");

idx = Locb(Lia);










