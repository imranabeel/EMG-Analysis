for i=1:numfiles
  file_name = csvfiles(i).name;
  fprintf('%s\n',file_name);
  
  data = csvread(file_name);
  
  emgData = data(:,2);
  L = length(emgData);
  
  FFT = fft(emgData);
  P2 = abs(FFT/L);
  P1 = P2(1:L/2+1);
  P1(2:end-1) = 2*P1(2:end-1);
  
  Fs = 1300; #Hz - taken from sample file
  f = Fs*(0:(L/2))/L;
  
  figure;
  hold on;
  plot(f,P1);
  title('Single-Sided Amplitude Spectrum of X(t)')
  xlabel('f (Hz)')
  ylabel('|P1(f)|')
  hold off;


  figure;
  hold on;
  plot(emgData);
  legend('Raw');
  title(file_name);
  
  
endfor
