for i=1:numfiles
  file_name = csvfiles(i).name;
  printf('%s\n',file_name);
  
  data = csvread(file_name);
  
  timebase = data(:,1);
  emgData = data(:,2);
  
  avgPeriod = 128;
  avgDelay = 6000;
  noiseBuff = ones(1, avgPeriod)*4095;
  noiseTotal =  avgPeriod * 4095;
  noiseIndex = 1;
  noiseAverage = noiseTotal/ avgPeriod;
  threshold = 100;
  noiseAdjustTimer = 0;
  
  processedData = zeros(1, length(data));
  noiseAvgPlot = zeros(1,length(data));
  oldTime = timebase(1);
  aboveThresholdTimerIsStarted = false;
  belowThresholdTimerIsStarted = false;
  
  for j = 1:length(emgData)
    raw = emgData(j);
    currentTime = timebase(j);
    
    if (raw > (noiseAverage + threshold)) #if raw value is over the noise floor+threshold
      belowThresholdTimerIsStarted = false;
      if (aboveThresholdTimerIsStarted == false) #start timer
        oldTime = currentTime;
        aboveThresholdTimerIsStarted = true;
      endif
    elseif (raw <= noiseAverage) #else if raw signal less than noise floor, update the noise floor using the raw signal
      noiseTotal = (noiseTotal - noiseBuff(noiseIndex))+raw; 
      
      #calculate rolling average noise floor
      noiseAverage = noiseTotal /  avgPeriod;
      noiseBuff(noiseIndex) = raw;
      noiseIndex++;
      if (noiseIndex >=  (avgPeriod+1)) 
        noiseIndex = 1;
      endif
      #reset timer
      oldTime = currentTime;
      aboveThresholdTimerIsStarted = false;
      belowThresholdTimerIsStarted = false;
    elseif (raw <= noiseAverage + threshold) #else, we're within the threshold amplitude. Reset timer, don't change noise floor.
      #reset timer
      
      aboveThresholdTimerIsStarted = false;
      if (belowThresholdTimerIsStarted == false)
        oldTime = currentTime;
        belowThresholdTimerIsStarted = true;
      endif
    endif
    
    #if threshold is allowed to creep up (i.e raw value has been over the noise floor, allow noise floor to creep)
    if ((aboveThresholdTimerIsStarted == true)||(belowThresholdTimerIsStarted == true))
      if ((currentTime-oldTime) > avgDelay)
        noiseTotal = (noiseTotal - noiseBuff(noiseIndex))+raw; #Update the noise floor using the raw signal
        
        #calculate rolling average noise floor
        noiseAverage = noiseTotal /  avgPeriod;
        noiseBuff(noiseIndex) = raw;
        noiseIndex++;
        if (noiseIndex >= (avgPeriod+1)) 
          noiseIndex = 1;
        endif
      endif
    endif
    
    #calculate signal by removing noise and thresh from raw (signal = raw - noise floor - threshold
    tempSig = raw - noiseAverage - threshold;
    if (tempSig < 0) 
      tempSig = 0;
    endif
    
    #add processed value to array for plotting.
    processedData(j) = tempSig;
    noiseAvgPlot(j) = noiseAverage;
  endfor
  
  
  
  figure;
  hold on;
  plotyy(timebase,emgData,timebase,noiseAvgPlot);
  plot(timebase,processedData);
  legend('Raw','Processed', 'Noise Average');
  title(file_name);
  
  figure; 
  plot(timebase,noiseAvgPlot);
  endfor