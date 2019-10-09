for i=1:numfiles
  file_name = csvfiles(i).name;
  fprintf('%s\n',file_name);
  
  data = csvread(file_name);
  
  emgData = data(:,1);
  
  figure;
  hold on;
  plot(emgData);
  legend('Raw');
  title(file_name);
endfor
