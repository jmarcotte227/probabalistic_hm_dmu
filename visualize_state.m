function visualize_state(state)
  [length,width] = size(state);

  map = [1, 1, 1;
         0, 0.5, 0;
         0, 1, 0];

  dx = 1;
  dy = 1;
  xg = linspace(0.5,0.5+width, width+1);
  yg = linspace(0.5,0.5+length, length+1);

  hold on
  imagesc(flip(state,1), [0,2]);
  colormap(map);
  hm = mesh(xg,yg,zeros(length+1,width+1));
  hm.FaceColor='none';
  hm.EdgeColor='k';
  set(gca, 'XTick', []);
  set(gca, 'Ytick', []);
  axis equal;
  xlim([0.5, width+0.5]);
  ylim([0.5, length+0.5]);
  hold off

              
end
