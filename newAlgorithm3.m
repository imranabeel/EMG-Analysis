for i=1:numfiles
  file_name = csvfiles(i).name;
  printf('%s\n',file_name);
  
  data = csvread(file_name);
  
  timebase = data(:,1);
  emgData = data(:,2);
  
  slopeAvgPeriod = 4;
  slopeBuff = ones(1, slopeAvgPeriod)*4095;
  slopeTotal =  slopeAvgPeriod * 4095;
  slopeIndex = 1;
  slopeAverage = slopeTotal/ slopeAvgPeriod;
  threshold = 50;
  
  avgPeriod = 128;
  noiseBuff = ones(1, avgPeriod)*190;
  noiseTotal =  avgPeriod * 190;
  noiseIndex = 1;
  noiseAverage = noiseTotal/ avgPeriod;
  noiseAdjustTimer = 0;
  
  processedData = zeros(1, length(data));
  noiseAvgPlot = zeros(1,length(data));
  slopeAvgPlot = zeros(1,length(data));
  slope = zeros(1,length(data));
  movingAverageSlope = 0;
  oldTime = timebase(1);
  aboveThresholdTimerIsStarted = false;
  belowThresholdTimerIsStarted = false;
  
  aboveThreshold = false;
  
  belowThresholdTimerStart = 0;
  
  oldRaw = emgData(1);
  oldTime = timebase(1);
  for j = 1:length(emgData)
    raw = emgData(j);
    currentTime = timebase(j);
    
    deltaTime = abs(oldTime - currentTime);
    if (deltaTime == 0) 
      deltaTime = 1;
    endif
    currentSlope = abs((raw-oldRaw)/deltaTime);   
    
    oldRaw = raw;
    oldTime = currentTime;
    
    #moving average slope
    slopeTotal = (slopeTotal - slopeBuff(slopeIndex))+currentSlope;
    slopeAverage = slopeTotal /  slopeAvgPeriod;
    slopeBuff(slopeIndex) = currentSlope;
    slopeIndex++;
    if (slopeIndex >=  (slopeAvgPeriod+1)) 
      slopeIndex = 1;
    endif
    if(raw>(noiseAverage+threshold))
    aboveThreshold = true;
    belowThresholdTimerIsStarted = false;
  else
    if (aboveThreshold == true) 
      if (belowThresholdTimerIsStarted == false)
        belowThresholdTimerIsStarted = true;
        belowThresholdTimerStart = currentTime;
      elseif ((currentTime - belowThresholdTimerStart)>100)
        aboveThreshold = false;
        belowThresholdTimerIsStarted  =false;
      endif
    else #below threshold and have been for a period of time.
      if (slopeAverage < 5) #prevent noise average changing if signal has steep slope.
        delta = raw - noiseAverage;
        if (delta < 10) #prevent noise average rising if delta change from the normal is too much.
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
    endif
  endif
  
  #calculate signal by removing noise and thresh from raw (signal = raw - noise floor - threshold
  tempSig = raw - noiseAverage;
  if (tempSig < 0) 
    tempSig = 0;
  endif
  
  #add processed value to array for plotting.
  emgData(j) = emgData(j);
  processedData(j) = (tempSig);
  noiseAvgPlot(j) = (noiseAverage);
  slopeAvgPlot(j) = slopeAverage;
  slope(j) = currentSlope;
endfor



figure;
hold on;
plotyy(timebase,emgData,timebase,processedData);
plotyy(timebase,emgData, timebase, noiseAvgPlot);
legend('Raw','Slope');
title('Processed vs Noise');

figure; 
hold on;
plot(timebase,noiseAvgPlot);
plot(timebase,slopeAvgPlot);
title('Noise vs Slope');

figure;
hold on;
#plot(timebase,slopeAvgPlot);

plot(timebase, noiseAvgPlot);
#plotyy(timebase,slopeAvgPlot, timebase, emgData);
endfor