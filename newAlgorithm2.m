for i=1:numfiles
  file_name = csvfiles(i).name;
  printf('%s\n',file_name);
  
  data = csvread(file_name);
  
  timebase = data(:,1);
  emgData = data(:,2);
  
  avgPeriod = 128;
  avgDelay = 1000;
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
  
  aboveThreshold = false;
  
  for j = 1:length(emgData)
    raw = emgData(j);
    currentTime = timebase(j);
    
    if (raw > (noiseAverage+threshold)) #valid measurement
      aboveThreshold = true;
      aboveThresholdTimerIsStarted = false;
    else #below threshold
      if (aboveThreshold) #just dipped back below threshold - ignore next 1 seconds of measurements.
        if (aboveThresholdTimerIsStarted == false)
          aboveThresholdTimerIsStarted = true;
          oldTime = currentTime;
        endif
        if ((currentTime - oldTime)>= avgDelay) #timer timeout
          aboveThreshold = false;
        endif
      else #below threshold, for greater than 1 seconds. Probably resting period. 
        noiseTotal = (noiseTotal - noiseBuff(noiseIndex))+raw; #Update the noise floor using the raw signal
        
        #calculate rolling average noise floor
        noiseAverage = noiseTotal /  avgPeriod;
        noiseBuff(noiseIndex) = raw;
        noiseIndex++;
        if (noiseIndex >=  (avgPeriod+1)) 
          noiseIndex = 1;
        endif
      endif
    endif
    
    
    
    #calculate signal by removing noise and thresh from raw (signal = raw - noise floor - threshold
    tempSig = raw - noiseAverage;
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
  plotyy(timebase,processedData, timebase, noiseAvgPlot);
  legend('Raw','Processed', 'Noise Average');
  title(file_name);
  
  figure; 
  plot(timebase,noiseAvgPlot);
  endfor