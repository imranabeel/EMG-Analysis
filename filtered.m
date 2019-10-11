for i=1:numfiles
  file_name = csvfiles(i).name;
  fprintf('%s\n',file_name);
  
  data = csvread(file_name);
  
  emgData = data(:,2);
  L = length(emgData);
  
  
  Fs = 1300;                                              #Sample Rate  
  Fn = Fs/2;                                              % Nyquist Frequency (Hz)
  Wp = 500/Fn;                                           % Passband Frequency (Normalised)
  Ws = 505/Fn;                                           % Stopband Frequency (Normalised)
  Rp =  1;                                               % Passband Ripple (dB)
  Rs = 150;                                               % Stopband Ripple (dB)
  [n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);                         % Filter Order
  [z,p,k] = cheby2(n,Rs,Ws,'low');                        % Filter Design
  [soslp,glp] = zp2sos(z,p,k);                            % Convert To Second-Order-Section For Stability
  figure(3);
  freqz(soslp, 2^16, Fs);                                  % Filter Bode Plot
  filtered = filtfilt(soslp, glp, emgData);

  figure;
  hold on;
  plot(emgData);
  plot(filtered);
  legend('Raw', 'Filtered');
  title(file_name);
endfor 
