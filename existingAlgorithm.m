for i=1:numfiles
  file_name = csvfiles(i).name;
  printf('%s\n',file_name);
  
  data = csvread(file_name);
  
  timebase = data(:,1);
  emgData = data(:,2);
  
  noiseBuff = ones(1,128)*4095;
  noiseTotal = 128 * 4095;
  noiseIndex = 1;
  noiseAverage = noiseTotal/128;
  threshold = 100;
  noiseAdjustTimer = 0;
  
  processedData = zeros(1, length(data));
  oldTime = timebase(1);
  timerIsStarted = false;
  for j = 1:length(emgData)
    raw = emgData(j);
    currentTime = timebase(j);
    
    if (raw > (noiseAverage + threshold)) 
      if (timerIsStarted == false)
        oldTime = currentTime;
        timerIsStarted = true;
      endif
      elseif (raw <= (noiseAverage + threshold)) 
        noiseTotal = (noiseTotal - noiseBuff(noiseIndex))+raw; #Update the noise floor using the raw signal
        noiseAverage = noiseTotal / 128;
        noiseBuff(noiseIndex) = raw;
        noiseIndex++;
        if (noiseIndex >= 129) 
          noiseIndex = 1;
         endif
         oldTime = currentTime;
         timerIsStarted = false;
      endif
      
      #if threshold is allowed to creep up
      if ((currentTime-oldTime) > 6000)  #6000 definitely needs adjusting! what is the sample rate?!
        noiseTotal = (noiseTotal - noiseBuff(noiseIndex))+raw; #Update the noise floor using the raw signal
        noiseAverage = noiseTotal / 128;
        noiseBuff(noiseIndex) = raw;
        noiseIndex++;
        if (noiseIndex >= 129) 
          noiseIndex = 1;
         endif
        endif
      
      #calculate signal by removing noise and thresh from raw (signal = raw - noise floor - threshold
      tempSig = raw - noiseAverage - threshold;
      if (tempSig < 0) 
        tempSig = 0;
        endif
      
      processedData(j) = tempSig;
    
    
  endfor
  
  figure;
  hold on;
  plot(timebase,emgData);
  plot(timebase,processedData);
  legend('Raw','Processed');
  title(file_name);
 
endfor